# 📊 ELK Exporter Deployment Guide

این پروژه شامل راه‌اندازی و پیکربندی **Elasticsearch Exporter** برای مانیتورینگ ELK Stack با استفاده از **Prometheus** و **Grafana** است.

---

## 🧩 معرفی

**Elasticsearch Exporter** ابزاری است که متریک‌های مرتبط با Elasticsearch (مثل وضعیت نودها، ایندکس‌ها و شاردها) را استخراج کرده و در اختیار **Prometheus** قرار می‌دهد تا بتوانیم در **Grafana** آن‌ها را مشاهده و تحلیل کنیم.

---

## ⚙️ پیش‌نیازها

قبل از شروع مطمئن شوید که موارد زیر روی سیستم شما نصب و آماده هستند:

- 🐳 [Docker](https://docs.docker.com/get-docker/)
- 📦 [Docker Compose](https://docs.docker.com/compose/)
- 📈 [Prometheus](https://prometheus.io/)
- 📊 [Grafana](https://grafana.com/)

---

## 🚀 نحوه راه‌اندازی Exporter

برای راه‌اندازی Elasticsearch Exporter کافی است فایل `docker-compose.yml` را با محتوای زیر ایجاد کنید:

```yaml
services:
  elasticsearch_exporter:
    image: harbor.u360.com/prometheuscommunity/elasticsearch-exporter:latest
    command:
      - '--es.uri=http://192.168.211.12:9200'
    restart: always
    ports:
      - "9114:9114"
```

سپس سرویس را با دستور زیر اجرا کنید:

```bash
docker compose up -d
```
✅ پس از اجرای موفق، کانتینر elasticsearch_exporter در پورت 9114 بالا می‌آید.


## 🔍 تنظیمات Prometheus
در فایل پیکربندی Prometheus (معمولاً prometheus.yml) بخش زیر را اضافه کنید تا Prometheus بتواند متریک‌های اکسپورتر را جمع‌آوری کند:
سپس Prometheus را ری‌لود کنید یا سرویس را ری‌استارت نمایید تا تنظیمات جدید اعمال شود.


## 🧪 بررسی وضعیت در Prometheus
برای اطمینان از عملکرد صحیح اکسپورتر:

وارد رابط وب Prometheus شوید (معمولاً در پورت 9090)

از منوی Status → Targets استفاده کنید

بررسی کنید که Target مربوط به Elk211.12 در وضعیت UP باشد ✅