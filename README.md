# 🚀 Prometheus Labs  

Welcome to **Prometheus Labs** – a hands-on playground for monitoring enthusiasts.  
This repo is designed to **explore Prometheus, exporters, alerting, dashboards, and advanced monitoring scenarios**.  

---

## 📌 Roadmap of Labs
We’ll go step by step, starting from the basics and moving towards advanced use cases:

1. 🖥️ Install and configure **Node Exporter**  
2. 📊 Setup **Prometheus server** and scrape targets  
3. 📈 Visualize metrics in **Grafana**  
4. 🚨 Define **alerting rules** and test with **Alertmanager**  
5. 🛠️ Custom exporters (write your own exporter in Python/Go)  
6. 🐳 Monitoring **Docker & Kubernetes clusters**  
7. ⚡ Advanced labs (Recording rules, Service discovery, Blackbox monitoring, etc.)

---

## 🖥️ Step 1: Install Node Exporter
First step: install **Node Exporter** to expose system metrics (CPU, memory, disk, network, …).  
Run the following commands on your target server:

```bash
wget https://raw.githubusercontent.com/sadeqrm/prometheus-labs/main/nodeexporter.sh -O nodeexporter.sh
chmod +x nodeexporter.sh
./nodeexporter.sh
```

Once running, Node Exporter exposes metrics on:
👉 http://<server-ip>:9100/metrics

For next step we need to install prometheus :
