# Terraform Modularisation Runbook

This document captures **exactly what has been done so far**, why it was done, and the **repeatable workflow** to safely modularise the rest of the infrastructure without losing work.

---

## 1. Objective

The goal of this project is to evolve a monolithic Terraform setup into a **clean, modular, production‑grade architecture** while also building strong Git/GitHub habits aligned with real‑world DevOps/Platform practices.

Key objectives:

* Modular Terraform (network, web, bastion, app, db)
* Clean root module (composition only)
* Safe Git branching & PR workflow
* No accidental loss of work
* Prepare for CI, multi‑env, Jenkins, EKS, monitoring, etc.

---

## 2. Branching Strategy (Single‑Repo, Multi‑Module)

### Main branches

| Branch               | Purpose                                            |
| -------------------- | -------------------------------------------------- |
| `main`               | Stable baseline with CI (GitHub Actions)           |
| `stantest`           | Legacy non‑modular Terraform (kept as reference)   |
| `feature/modularise` | **Integration branch** for all modularisation work |

### Feature branches

One feature branch **per module**, always created from `feature/modularise`:

* `feature/network-module`
* `feature/web-module`
* `feature/bastion-module`
* `feature/app-module`
* `feature/db-module`

Each feature branch is short‑lived and merged back via PR.

---

## 3. Terraform Structure (After Network Modularisation)

### Root module (repo root)

The root module is now **composition‑only**.

Contains:

* Provider configuration
* `terraform { required_providers }`
* Module calls
* Root‑level variables

Does **NOT** contain:

* `aws_vpc`
* `aws_subnet`
* `aws_route_table`
* Any direct infrastructure resources

This keeps the root clean and scalable.

---

### Modules layout

```
modules/
  network/
    main.tf        # actual resources
    variables.tf   # module inputs
    outputs.tf     # exported values
```

Each module is:

* Self‑contained
* Testable in isolation
* Reusable

---

## 4. What Happened to Legacy Root Terraform Files

### Problem

Terraform automatically loads **all `.tf` files in the root directory**. While modularising, legacy files caused:

* Terraform planning unintended resources
* Large diffs
* Merge conflicts
* High risk of accidental apply/destroy

### Solution (Chosen Approach)

Legacy root `.tf` files were **archived**, not deleted:

```
_archive/
  root_tf_disabled/
    subnet.tf
    security_group.tf
    aws_lb.tf
    launch_template.tf
    ...
```

Why this works:

* Terraform ignores sub‑directories unless referenced as modules
* Git tracks this as renames (history preserved)
* Noise removed from active configuration

---

## 5. Network Module: What Was Built

The `modules/network` module provides:

* VPC
* Public subnets (2)
* Private subnets (2)
* DB subnets (2)
* DB subnet group
* Internet Gateway
* Elastic IP
* NAT Gateway
* Public route table + associations
* Private route table + associations

### Outputs include:

* `vpc_id`
* subnet IDs
* route table IDs
* NAT / IGW IDs

These outputs form the **contract** used by downstream modules.

---

## 6. Git Workflow Used for Network Module

### Step 1: Create feature branch

```bash
git checkout feature/modularise
git pull
git checkout -b feature/network-module
```

### Step 2: Implement + test locally

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply   # only when confident
```

### Step 3: Commit & push

```bash
git add -A
git commit -m "Modularise network layer and archive legacy root Terraform files"
git push -u origin feature/network-module
```

### Step 4: Pull Request

* PR: `feature/network-module → feature/modularise`
* Merge strategy: **Squash & Merge**

Why squash:

* One commit per module
* Clean integration branch history
* PR still shows step‑by‑step work

### Step 5: Sync integration branch

```bash
git checkout feature/modularise
git pull
```

---

## 7. Module Boundary Discipline (Critical Rule)

Once a resource lives in a module:

✅ Downstream modules must use outputs:

```hcl
module.network.vpc_id
module.network.public_subnet_ids
```

❌ Never reference internal resources directly:

```hcl
aws_vpc.arco_infra.id   # ❌ forbidden outside network module
```

This rule prevents tight coupling and future refactor pain.

---

## 8. Current State (Post‑Merge)

* Network module merged into `feature/modularise`
* Root cleaned and stable
* Legacy files archived
* `.gitignore` fixed to exclude Terraform state

Recommended cleanup:

```bash
git branch -d feature/network-module
git push origin --delete feature/network-module
```

---

## 9. Repeatable Workflow for All Remaining Modules

For **each module** (web, bastion, app, db):

1. Checkout integration branch

```bash
git checkout feature/modularise
git pull
```

2. Create module branch

```bash
git checkout -b feature/<module>-module
```

3. Create module structure

```
modules/<module>/
  main.tf
  variables.tf
  outputs.tf
```

4. Wire module in root `main.tf`

5. Test locally

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

6. Commit & push

```bash
git add -A
git commit -m "Modularise <module> layer"
git push -u origin feature/<module>-module
```

7. PR → **Squash & Merge** → `feature/modularise`

8. Pull integration branch

```bash
git checkout feature/modularise
git pull
```

---

## 10. Planned Future Enhancements

* Merge `feature/modularise` → `main`
* Re‑enable / refine CI checks
* Multi‑environment support (dev/test/prod)
* Jenkins pipeline (Makefile‑driven)
* Security hardening (SGs, IAM, scanning)
* Monitoring (Grafana, Prometheus)
* EKS + Helm + k9s

---

## 11. Golden Rule

> **Never work directly on `main`.**
>
> Always:
>
> * isolate changes
> * test locally
> * PR into an integration branch
> * keep commits intentional


---
