# Network Topology: Proxmox-Ops

This document describes the virtualized networking strategy across LXC containers, VMs, and software-defined network segments within the Proxmox-Ops project.

---

## 🌐 Proxmox Virtual Bridges

### `vmbr0`
- Default bridge for most LXCs and VMs
- Bridged to the LAN through Proxmox's physical NIC
- DHCP-enabled or static IP via external router
- Used for:
  - n8n + postgres stack
  - Admin tools
  - Application frontends

Future planned bridges:
- `vmbr1`: Isolated backend services
- `vmbrDMZ`: Public-facing services or reverse proxies

---

## 🔗 LXC Stack Network Strategies

### n8n + PostgreSQL Stack
- Both containers attached to `vmbr0`
- Each receives its own IP from LAN or DHCP pool
- Direct IP-to-IP communication without NAT

### Planned: Docker Overlay or VXLAN
- For stacks deployed via Docker Swarm or k3s
- Virtual networks span multiple LXCs using `overlay` driver
- Facilitates service-to-service networking across containers

---

## 📡 Example: Multi-Stack Network Topology (Future)

```
            +-------------------+
LAN <--> vmbr0  | n8n container     |
                | 10.0.0.101        |
                +-------------------+

                +-------------------+
LAN <--> vmbr0  | Postgres container|
                | 10.0.0.102        |
                +-------------------+

                +-------------------+
vmbr1  <-->     | Docker Swarm Node |
                | Overlay Net: 172.18.x.x
                +-------------------+
```

---

## 🛠️ Design Considerations

- **Simplicity First**: Most stacks use flat Layer 2 IP assignments via `vmbr0`
- **Modular Isolation**: Future bridges (`vmbr1`, `vmbrDMZ`) support stack segmentation
- **Performance**: No NAT within bridge—raw container IPs are addressable
- **Resilience**: Consider network namespaces or proxy layers for failover

---

## 🔧 Future Enhancements

- Define DNS overlay for internal service resolution
- Integrate Tailscale or Wireguard for remote access to virtual networks
- Implement firewall rules or tagging based on bridge mappings
