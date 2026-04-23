#!/usr/bin/env bash

echo "========================================="
echo " Linux Hardening Audit"
echo "========================================="
echo

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; }

# ------------------------------------------------
# Boot security
# ------------------------------------------------

if ls /boot/*rescue* >/dev/null 2>&1; then
    fail "Rescue boot entries removed"
else
    pass "Rescue boot entries removed"
fi

# ------------------------------------------------
# Compiler restriction
# ------------------------------------------------

check_compiler() {
    local file=$1
    if [ -f "$file" ]; then
        perm=$(stat -c "%a" "$file")
        if [ "$perm" = "700" ]; then
            pass "Compiler restricted: $file"
        else
            fail "Compiler not restricted: $file"
        fi
    fi
}

check_compiler /usr/bin/gcc
check_compiler /usr/bin/g++
check_compiler /usr/bin/cc
check_compiler /usr/bin/make

# ------------------------------------------------
# AppArmor
# ------------------------------------------------

if command -v aa-status >/dev/null 2>&1; then
    if aa-status --enabled >/dev/null 2>&1; then
        pass "AppArmor enabled"
    else
        fail "AppArmor installed but not enabled"
    fi
else
    fail "AppArmor not installed"
fi

# ------------------------------------------------
# Kernel hardening
# ------------------------------------------------

check_sysctl() {
    param=$1
    expected=$2
    value=$(sysctl -n "$param" 2>/dev/null)

    if [ "$value" = "$expected" ]; then
        pass "$param = $expected"
    else
        fail "$param expected $expected but found $value"
    fi
}

check_sysctl kernel.randomize_va_space 2
check_sysctl kernel.kptr_restrict 2
check_sysctl fs.protected_symlinks 1
check_sysctl fs.protected_hardlinks 1

# ------------------------------------------------
# File permissions
# ------------------------------------------------

check_perm() {
    file=$1
    perm_expected=$2
    owner_expected=$3

    perm=$(stat -c "%a" "$file")
    owner=$(stat -c "%U:%G" "$file")

    if [ "$perm" = "$perm_expected" ] && [ "$owner" = "$owner_expected" ]; then
        pass "$file permissions secure"
    else
        fail "$file permissions incorrect"
    fi
}

check_perm /etc/shadow 000 root:root
check_perm /etc/passwd 644 root:root
check_perm /etc/group 644 root:root
check_perm /etc/sudoers 440 root:root
check_perm /etc/fstab 644 root:root
check_perm /root 700 root:root

echo
echo "========================================="
echo " Audit complete"
echo "========================================="
