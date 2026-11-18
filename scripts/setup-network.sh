#!/bin/bash
set -e

ip netns del site-a 2>/dev/null || true
ip netns del site-b 2>/dev/null || true
ip netns del nexus-router 2>/dev/null || true
ip link del a-host 2>/dev/null || true
ip link del b- host 2>/dev/null || true

ip netns add site-a
ip netns add site-b
ip netns add nexus-router

ip link add a-host type veth peer name a-rtr
ip link add b-host type veth peer name b-rtr

ip link set a-host netns site-a
ip link set a-rtr netns nexus-router
ip link set b-host netns site-b
ip link set b-rtr netns nexus-router

ip -n site-a link set lo up
ip -n site-a addr add 10.10.1.10/24 dev a-host
ip -n site-a link set a-host up
ip -n site-a route add default via 10.10.1.1

ip -n site-b link set lo up
ip -n site-b addr add 10.20.1.10/24 dev b-host
ip -n site-b link set b-host up
ip -n site-b route add default via 10.20.1.1

ip -n nexus-router link set lo up
ip -n nexus-router addr add 10.10.1.1/24 dev a-rtr
ip -n nexus-router addr add 10.20.1.1/24 dev b-rtr
ip -n nexus-router link set a-rtr up
ip -n nexus-router link set b-rtr up
ip netns exec nexus-router sysctl -q -w net.ipv4.ip_forward=1

echo "NexusHA network created successfully"
