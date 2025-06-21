

<a id="readme-top"></a>



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/daniel-fmendez/XDPGuardian">
    <img src="images/icon.png" alt="Logo" width="156" height="156">
  </a>

<h3 align="center">XDPGuardian</h3>

  <p align="center">
    Lightweight and efficient Linux network control, optimized with eBPF/XDP
    <br />

</div>





<!-- ABOUT THE PROJECT -->
## About The Project

XDPGuardian is an administrator tool designed to monitor, analyze, and block incoming traffic using eBPF/XDP technology.

It provides fine-grained control over low-level packet filtering directly in the Linux kernel, while offering a user-friendly `Qt-based` graphical interface for real-time monitoring and rule management. The tool supports protocol-, IP-, and port-based filtering, and includes built-in mitigation against common DoS attacks such as SYN Floods.


### Installation


1. Download the latest **`XDPGuardian-x86_64.AppImage`** from the Releases page.  
2. Make it executable:
   ```bash
   chmod +x XDPGuardian-x86_64.AppImage
3. Run the application using a user with `sudo` privileges:
   ```bash
   ./XDPGuardian-x86_64.AppImage
<!-- If you prefer to build XDPGuardian from source, please refer to the BUILDING.md for detailed instructions. -->





<!-- USAGE EXAMPLES -->
## Usage

This version of **XDPGuardian** is optimized to run efficiently even on low-resource devices. The system operates at the kernel level using eBPF/XDP technology to analyze and filter incoming network traffic with minimal overhead.

- You can insert up to **8192 simultaneous rules** from the graphical interface.
- Rules can be based on:
  - Source or destination IP addresses
  - Protocols (TCP, UDP)
  - Port numbers (when applicable)

The graphical interface allows real-time monitoring and control, including:
- Visual representation of traffic distribution by protocol, size, and port.
- Rule management with simple point-and-click interaction.
- Live stats and automatic detection of unusual patterns, such as potential DoS attacks.

To start using:
1. Run the AppImage as described in the [Installation](#installation) section.
2. Grant root privileges when prompted (required for low-level network access).
3. Use the GUI to monitor traffic, add rules, or inspect real-time network behavior.

The tool is ideal for:
- System administrators securing Linux servers
- Developers testing custom network scenarios
- Enthusiasts learning eBPF/XDP-based filtering
- Newcomers learning the fundamentals of network management