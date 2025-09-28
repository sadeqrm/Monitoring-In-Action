# Prometheus Monitoring Architecture and Practical Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Prometheus Architecture](#prometheus-architecture)
   - [Core Components](#core-components)
   - [How Prometheus Works](#how-prometheus-works)
3. [Key Components Explained](#key-components-explained)
   - [Prometheus Server](#prometheus-server)
   - [Alertmanager](#alertmanager)
   - [Pushgateway](#pushgateway)
   - [Grafana](#grafana)
   - [cAdvisor](#cadvisor)
4. [Prometheus Metric Types](#prometheus-metric-types)
   - [Counter](#counter)
   - [Gauge](#gauge)
   - [Histogram](#histogram)
   - [Summary](#summary)
5. [Practical Examples](#practical-examples)
   - [Monitoring Docker Containers with cAdvisor](#monitoring-docker-containers-with-cadvisor)
   - [Scraping Custom Metrics](#scraping-custom-metrics)
   - [Using Alertmanager for Alerts](#using-alertmanager-for-alerts)
   - [Visualizing Metrics in Grafana](#visualizing-metrics-in-grafana)
6. [References](#references)

---

## Introduction
Prometheus is an open-source monitoring and alerting toolkit designed for reliability and scalability. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays results, and triggers alerts when conditions are met.  

Prometheus is often paired with **Grafana** for visualization and **cAdvisor** for container-level metrics collection.

---

## Prometheus Architecture

### Core Components
- **Prometheus Server**: Collects and stores metrics in a time-series database.
- **Exporters**: Components that expose metrics from third-party systems (e.g., node_exporter, cAdvisor).
- **Alertmanager**: Handles alerts sent by Prometheus server and manages notifications (email, Slack, etc.).
- **Pushgateway**: Allows ephemeral jobs to push metrics to Prometheus.
- **Grafana**: Visualization tool to create dashboards from Prometheus metrics.

### How Prometheus Works
1. Prometheus scrapes metrics from endpoints (`/metrics`) periodically.
2. Metrics are stored in a time-series database.
3. Rules are evaluated to trigger alerts.
4. Alertmanager sends notifications.
5. Grafana queries Prometheus to display dashboards.

---

## Key Components Explained

### Prometheus Server
- Collects metrics from targets via HTTP.
- Stores metrics in **time-series format**.
- Evaluates alerting and recording rules.

### Alertmanager
- Deduplicates, groups, and routes alerts.
- Supports multiple notification channels (Slack, Email, PagerDuty).
- Handles silencing and inhibition of alerts.

### Pushgateway
- Useful for short-lived jobs that cannot be scraped.
- Jobs push metrics to Pushgateway, Prometheus scrapes them later.

### Grafana
- Dashboard and visualization platform.
- Queries Prometheus as a data source.
- Supports alerts visualization.

### cAdvisor
- Container Advisor for monitoring Docker containers.
- Exposes metrics such as CPU, memory, network, and filesystem usage.
- Metrics are available at `http://<host>:8080/metrics`.

---

## Prometheus Metric Types

### Counter
- **Definition**: Monotonically increasing value, can only go up.
- **Example**: Number of HTTP requests.
```text
http_requests_total{method="GET", handler="/api"} 1027
