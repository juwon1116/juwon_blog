---
layout: post
read_time: true
show_date: true
title: "Nginx 로드 밸런서로 Django 분산 처리하기"
date: 2025-11-22
description: Quiz_AI 서버에서 Nginx `upstream`과 Gunicorn 다중 인스턴스로 로드 밸런싱을 적용한 기록.
tags: [devops, nginx, django, load-balancing, ubuntu]
author: Juwon
---
## 1. 목표: Django 서버를 두 개로 나눠 받고 Nginx로 분산하기

기존 구조는:

- Nginx  
- → Gunicorn (Django) 1개  
- → `127.0.0.1:8000` 으로만 연결

오늘 목표는:

- Gunicorn 프로세스 2개 (8000, 8001)  
- Nginx `upstream` 으로 두 포트에 로드 밸런싱

---

## 2. 기존 Nginx 설정 확인 (quizai.juwonpark.me)

원래 `quizai.juwonpark.me` Nginx 설정은 대략 이렇게 되어 있었다.

```nginx
server {
    listen 80;
    server_name quizai.juwonpark.me 3.38.116.255 127.0.0.1 localhost;

    client_max_body_size 100M;
    client_body_timeout 300s;
    client_body_buffer_size 512k;

    location = /favicon.ico {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/staticfiles/quiz_app/favicon.ico;
        access_log off;
        log_not_found off;
    }

    location /static/ {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/staticfiles/;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location /media/ {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/media/;
        add_header Cache-Control "public, max-age=604800";
        access_log off;
        expires 7d;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;  # 단일 포트
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_request_buffering off;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
    }
}
```

즉, **한 포트(8000)에만 프록시**하고 있었음.

---

## 3. Nginx에 `upstream` 추가해서 로드 밸런싱 적용

여기에 **로드 밸런서 역할**을 시키기 위해 `upstream` 블록을 추가하고,
`proxy_pass` 대상을 `127.0.0.1:8000` → `quiz_backend` 로 변경했다.

```nginx
# 1) server 블록 위에 upstream 추가
upstream quiz_backend {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
}

# 2) server 블록의 location / 수정
server {
    listen 80;
    server_name quizai.juwonpark.me 3.38.116.255 127.0.0.1 localhost;

    client_max_body_size 100M;
    client_body_timeout 300s;
    client_body_buffer_size 512k;

    location = /favicon.ico {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/staticfiles/quiz_app/favicon.ico;
        access_log off;
        log_not_found off;
    }

    location /static/ {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/staticfiles/;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location /media/ {
        alias /home/ubuntu/Q_park_final/Quiz_AI/testpro/media/;
        add_header Cache-Control "public, max-age=604800";
        access_log off;
        expires 7d;
    }

    location / {
        proxy_pass http://quiz_backend;   # ← upstream 이름으로 변경

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_request_buffering off;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
    }
}
```

적용 순서:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 4. Gunicorn systemd 서비스 두 개로 분리

### 4.1 기존 `quizai.service` 오타 수정

기존 서비스 파일:

```ini
[Unit]
Description=Quiz_AI Django Service
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/Q_park_final/Quiz_AI/testpro
Environment="DJANGet_SETTINGS_MODULE=mysite.settings"
ExecStart=/home/ubuntu/Q_park_final/Quiz_AI/.venv/bin/gunicorn \
          mysite.wsgi:application \
          --bind 127.0.0.1:8000 \
          --workers 3
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

여기서 `Environment` 부분에 **오타**가 있어서 수정:

```ini
Environment="DJANGO_SETTINGS_MODULE=mysite.settings"
```

그리고 Description만 살짝 바꿔서 정리:

```ini
[Unit]
Description=Quiz_AI Django Service (8000)
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/Q_park_final/Quiz_AI/testpro
Environment="DJANGO_SETTINGS_MODULE=mysite.settings"

ExecStart=/home/ubuntu/Q_park_final/Quiz_AI/.venv/bin/gunicorn \
          mysite.wsgi:application \
          --bind 127.0.0.1:8000 \
          --workers 3

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 4.2 `quizai-2.service` 생성 (포트 8001)

서비스 파일을 그대로 복사해서 두 번째 인스턴스를 만들었다.

```bash
sudo cp /etc/systemd/system/quizai.service /etc/systemd/system/quizai-2.service
sudo vim /etc/systemd/system/quizai-2.service
```

내용에서 **포트만 8001로 변경**:

```ini
[Unit]
Description=Quiz_AI Django Service (8001)
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/Q_park_final/Quiz_AI/testpro
Environment="DJANGO_SETTINGS_MODULE=mysite.settings"

ExecStart=/home/ubuntu/Q_park_final/Quiz_AI/.venv/bin/gunicorn \
          mysite.wsgi:application \
          --bind 127.0.0.1:8001 \
          --workers 3

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 4.3 systemd 리로드 + 서비스 시작

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now quizai.service quizai-2.service

sudo systemctl status quizai.service
sudo systemctl status quizai-2.service
```

정상일 때 `journalctl -u` 로그:

```text
[INFO] Listening at: http://127.0.0.1:8000 ...
[INFO] Listening at: http://127.0.0.1:8001 ...
```

그리고 `ss`로 포트 확인:

```bash
sudo ss -lntp | grep 800
```

---

## 5. 적용 후 검증 포인트

설정만 넣고 끝내지 말고, 아래 순서로 확인하면 좋다.

```bash
sudo nginx -t
curl -I http://127.0.0.1
for i in {1..5}; do curl -s http://127.0.0.1 >/dev/null; done
sudo tail -f /var/log/nginx/access.log
```

특히 `journalctl -u quizai.service -u quizai-2.service -f`를 같이 열어두면,
요청이 두 Gunicorn 인스턴스로 분산되는지 감을 잡기 쉽다.

---

## 6. 운영할 때 주의할 점

로드 밸런싱 자체는 간단하지만, 애플리케이션이 상태를 어디에 저장하는지는 별개 문제다.

* 세션/캐시를 프로세스 메모리에만 두면 인스턴스가 둘일 때 동작이 꼬일 수 있다.
* 업로드 파일을 로컬 디스크에만 두면 어느 인스턴스로 붙느냐에 따라 파일이 안 보일 수 있다.
* 헬스체크 없이 프로세스만 늘리면 죽은 백엔드로도 트래픽을 보내는 상황이 생길 수 있다.

그래서 실무에서는 Redis 같은 공용 저장소, 정적/미디어 분리, 헬스체크까지 같이 보는 편이 맞다.

---

## 7. 오늘 작업 요약

* Nginx에 `upstream quiz_backend` 추가해서
  `127.0.0.1:8000`, `127.0.0.1:8001` 두 포트로 로드 밸런싱 설정
* `quizai.service` 오타 수정 (`DJANGet_SETTINGS_MODULE` → `DJANGO_SETTINGS_MODULE`)
* `quizai-2.service` 생성해서 Gunicorn 두 번째 인스턴스를 8001 포트에 바인딩
* `systemctl`/`journalctl`/`ss` 명령으로 서비스와 포트 상태 확인

이번에 해본 셋업은 나중에 **EC2 여러 대로 확장하거나,
ALB 환경으로 넘어갈 때도 기본이 되는 패턴**이라,
오늘 작업은 “미니 로드밸런서 실습” 느낌으로 잘 정리된 하루였다.
