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

#### ✅ Verification
Once everything is up, open the Prometheus web UI at:

    👉 http://<server-ip>:9090
    You should see the Prometheus dashboard.
    From here, we can move to adding more scrape targets, rules, and dashboards.
---

## 📡 Step 2.1: Add a Scraper Target to Prometheus  

Now that Prometheus is installed and running, we need to **add targets** for scraping metrics.  
By default, the config only scrapes the local Node Exporter (`127.0.0.1:9100`).  
Let’s add another Node Exporter instance running on a remote server at **192.168.6.46:9100**.  

---

### 📝 Update `prometheus.yml`
Open the Prometheus configuration file:  

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Find the scrape_configs section and update it as follows:
```bash
scrape_configs:
  # Local Node Exporter
  - job_name: 'NodeExporter-local'
    static_configs:
      - targets:
          - 127.0.0.1:9100

  # Remote Node Exporter
  - job_name: 'NodeExporter-remote'
    static_configs:
      - targets:
          - 192.168.6.46:9100
```

#### 🔄 Apply the Changes
Reload Prometheus so it picks up the new configuration:
```bash
sudo systemctl restart prometheus
sudo systemctl status prometheus
```
#### ✅ Verify in Prometheus UI

Open the Prometheus web interface:
👉 http://<prometheus-server-ip>:9090/targets

Under Targets, you should now see both:

*  NodeExporter-local → 127.0.0.1:9100
*  NodeExporter-remote → 192.168.6.46:9100
  
#### Both should show as UP if Prometheus can reach them.
---

## 🎨 Step 3: Install Grafana on Debian / Ubuntu  

To visualize the metrics collected by Prometheus, next we will install Grafana on your Debian/Ubuntu server.  
Choose one of the installation methods below (APT repository is recommended for easy upgrades).

---

### 🧰 Method A: Install via APT Repository (Recommended)

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana
```

*  This adds Grafana Labs’s repository to your system so Grafana can be updated automatically.
*  Installs the OSS (open source) edition by default.

### 🛠 Method B: Install via .deb Package

Go to the Grafana download page and select the version you want.
Download the .deb for Debian/Ubuntu.

Install with dpkg v12.1.1:
```bash
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/grafana/release/12.1.1/grafana_12.1.1_16903967602_linux_amd64.deb
sudo dpkg -i grafana_12.1.1_16903967602_linux_amd64.deb
```
#### 🚀 Start Grafana
After installation using any of the above methods:
```bash
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```
---

## 📈 Step 3: Visualize Metrics in Grafana  

Now that Grafana is installed and running, let’s use it to visualize the metrics we’re scraping with Prometheus.  

---

### 🔌 3.1 Add Prometheus as a Data Source  

1. Open Grafana in your browser:  
   👉 `http://<grafana-server-ip>:3000`  

2. Login with default credentials (user: `admin`, password: `admin`)  

3. In the left menu, go to:  
   **Connections → Data sources → Add data source**  

4. Select **Prometheus**  

5. Configure the following:  
   - **URL:** `http://<prometheus-server-ip>:9090`  
   - Leave other settings as default  

6. Click **Save & test**.  
   If everything is correct, you should see `Data source is working`.  

---

### 📊 3.2 Import Node Exporter Dashboard  

Instead of building dashboards from scratch, we can import community dashboards for Node Exporter.  

1. In Grafana’s left menu, click:  
   **Dashboards → + Import**  

2. Enter a dashboard ID from [Grafana Dashboards](https://grafana.com/grafana/dashboards/) gallery.  
   A popular one for Node Exporter is: **1860**  

3. Click **Load**  

4. Select your Prometheus data source when prompted  

5. Click **Import**  

Now you should see a detailed dashboard with metrics like:  
- CPU usage  
- Memory utilization  
- Disk I/O  
- Network traffic  
<p align="center">
  <img width="1536" height="934" alt="image" src="https://github.com/user-attachments/assets/659d5820-af5d-49e3-888e-b50aae5804f7" />
</p>


---

### ✅ Result  

At this point, Grafana is connected to Prometheus and visualizing metrics from your Node Exporter instances.  
You can repeat the same process to import dashboards for other exporters (e.g. Docker, Kubernetes, databases).  

👉 Next step: we’ll move on to **Alerting** using Prometheus + Alertmanager.  

---

## 🚨 Step 4: Alerting with Prometheus & Alertmanager  

Now that we have Prometheus scraping metrics and Grafana visualizing them, the next step is to configure **Alerting**.  
This involves two parts:  
1. Installing and configuring **Alertmanager**  
2. Defining **alerting rules** in Prometheus (e.g. CPU > 80%)  

---

### ⚙️ 4.1 Install Alertmanager  

We use the script [`alertmanager-install.sh`](/Session13/Alerting-Installation/alertmanager-install.sh) which:  
- Downloads and installs Alertmanager  
- Creates a system user  
- Sets up a configuration for **Telegram notifications**  
- Creates a systemd service  

Run the script:  

```bash
chmod +x alertmanager-install.sh
sudo ./alertmanager-install.sh
```
After installation, Alertmanager will be running on:
👉 http://<server-ip>:9093


