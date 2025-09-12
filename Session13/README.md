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
wget https://raw.githubusercontent.com/sadeqrm/Monitoring-In-Action/main/Session13/NodeExporter-Installation/nodeexporter.sh
chmod +x nodeexporter.sh
./nodeexporter.sh
```

Once running, Node Exporter exposes metrics on:
👉 http://<server-ip>:9100/metrics

For next step we need to install prometheus :

---

## 📊 Step 2: Setup Prometheus Server  
```bash
wget https://raw.githubusercontent.com/sadeqrm/Monitoring-In-Action/main/Session13/Prometheus-Installation/prometheusinstallation.sh
chmod +x prometheusinstallation.sh
./prometheusinstallation.sh
```
In this step, we will install and configure **Prometheus Server** using the provided script [`prometheusinstallation.sh`](./Prometheus-Installation/prometheusinstallation.sh).  
This script automates the setup, but let’s break it down to understand each part.


---

### 📥 1. Download and Extract Prometheus
```bash
export RELEASE="3.5.0"
wget https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz
tar xvf prometheus-${RELEASE}.linux-amd64.tar.gz
cd prometheus-${RELEASE}.linux-amd64/
```
*  Define which version to install using the RELEASE variable
*  Download the official Prometheus binary from GitHub
*  Extract the archive and move into the directory
### 👤 2. Create Prometheus User and Group
```bash
groupadd --system prometheus
grep prometheus /etc/group
useradd -s /sbin/nologin -r -g prometheus prometheus
```
*  Add a dedicated system group prometheus
*  Verify the group creation
*  Add a system user prometheus with no login shell (for security)

### 📑 4. Copy Binaries and Console Files
```bash
cp prometheus promtool /usr/local/bin/
cp -r consoles/ console_libraries/ /etc/prometheus/
```
*  Move binaries (prometheus, promtool) into /usr/local/bin
*  Copy console templates and libraries into Prometheus config directory

### 🔧 5. Create Systemd Service File
```bash
echo -n "[Unit]
Description=Prometheus systemd service unit
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090
SyslogIdentifier=prometheus
Restart=always
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/prometheus.service >/dev/null
```
*  Defines how Prometheus runs as a service
*  Runs under the prometheus user
*  Listens on port 9090

### 📝 6. Create Prometheus Configuration File
```bash
echo -n " # my global config
global:
  scrape_interval: 15s
  evaluation_interval: 15s
rule_files:
  - 'alerts/*.yml'
alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
scrape_configs:
  - job_name: 'NodeExporter'
    metrics_path: /metrics
    static_configs:
         - targets:
            - 127.0.0.1:9100
" | tee /etc/prometheus/prometheus.yml > /dev/null
```
Key parts of prometheus.yml:
  *  global: scraping and evaluation intervals (default: 15s)
  *  rule_files: location for alert rules
  *  alerting: connection to Alertmanager
  *  scrape_configs: by default, scrape Node Exporter at 127.0.0.1:9100
### 🔒 7. Set Ownership and Permissions
```bash
chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
chmod -R 775 /etc/prometheus/ /var/lib/prometheus/
```
*  Make prometheus the owner of config and data directories
*  Apply secure permissions

### 🚀 8. Start and Enable Prometheus Service
```bash
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus
```
*  Reload systemd to register the new service
*  Start Prometheus
*  Enable it at boot
*  Check its running status

## ✅ Verification
Once everything is up, open the Prometheus web UI at:

    👉 http://<server-ip>:9090
    You should see the Prometheus dashboard.
    From here, we can move to adding more scrape targets, rules, and dashboards.
