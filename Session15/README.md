<h1 align="center">📊 ELK Exporter Deployment Guide </h1>

<h3 align="center">
راهنمای استقرار و مانیتورینگ <b>Elasticsearch Exporter</b> با <b>Prometheus</b> و <b>Grafana</b>
</h3>


## 🧩 معرفی

<div dir="rtl">

الستیک سرچ اکسپورتر ابزاری است که با نصب آن متریک های مرتبط با elasticsearch (مثل وضعیت نودها، ایندکس‌ها و شاردها) را استخراج کرده و در اختیار **Prometheus** قرار می‌دهد تا بتوانیم در **Grafana** آن‌ها را مشاهده و تحلیل کنیم.
 
 

</div>


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
  
 1. وارد رابط وب Prometheus شوید (معمولاً در پورت 9090)
  
 2. از منوی Status → Targets استفاده کنید

 3. بررسی کنید که Target مربوط به Elk211.12 در وضعیت UP باشد ✅
<img width="1889" height="375" alt="image" src="https://github.com/user-attachments/assets/83bdea79-8234-4470-869c-a10eca89092e" />


##
📊 ایمپورت داشبورد در Grafana
برای مشاهده‌ی متریک‌ها در Grafana:
1.	وارد محیط Grafana شوید
2.	از منوی Dashboards → Import استفاده کنید
3.	فایل داشبورد آماده‌ی شما به نام elk-dashboard.json را انتخاب و آپلود کنید
4.	داشبورد به‌صورت خودکار متریک‌های مربوط به Elasticsearch را نمایش می‌دهد

<img width="1649" height="915" alt="image" src="https://github.com/user-attachments/assets/08007c16-8e2d-4a20-ad33-4a5273ae1f9d" />

## 🏁 نتیجه نهایی

پس از انجام مراحل بالا، داده‌های Elasticsearch از طریق Elasticsearch Exporter در Prometheus جمع‌آوری می‌شوند و با استفاده از داشبورد elk-dashboard.json در Grafana قابل مشاهده خواهند بود 🎯
