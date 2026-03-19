<#
  Refactor-DataArchDoc.ps1
  Applies all remaining table column removals and header emoji additions to data-architecture.md
#>

$f = "z:\APIM-Accelerator\docs\architecture\data-architecture.md"
$c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$orig = $c.Length
Write-Host "Loaded: $orig chars"

# ══════════════════════════════════════════════════════
# SECTION 1 — Key Findings table header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Finding                                    | Detail                                                            | Severity      |",
    "| 🔍 Finding | 📝 Detail | ⚠️ Severity |"
)
$c = $c.Replace(
    "| ------------------------------------------ | ----------------------------------------------------------------- | ------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 1 — Data Quality Scorecard: remove Evidence column
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Dimension               | Score   | Assessment                                                              | Evidence                                          |",
    "| 📐 Dimension | 🎯 Score | 📊 Assessment |"
)
$c = $c.Replace(
    "| ----------------------- | ------- | ----------------------------------------------------------------------- | ------------------------------------------------- |",
    "| --- | --- | --- |"
)
# Remove last column from each scorecard data row
$c = $c.Replace(" | src/shared/common-types.bicep:1-155               |", " |")
$c = $c.Replace(" | Multiple files                                    |", " |")
$c = $c.Replace(" | infra/settings.yaml:29-39                         |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:118-126                |", " |")
$c = $c.Replace(" | src/core/apim.bicep:256-310                       |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:110-140 |", " |")
$c = $c.Replace(" | src/core/apim.bicep:256-295                       |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:1-200                  |", " |")

# ══════════════════════════════════════════════════════
# SECTION 2 — All 11 subsection table headers (Name|Description|Classification)
# ══════════════════════════════════════════════════════
$sec2OldHdr = "| Name                   | Description                                                                                                 | Classification |"
$sec2NewHdr = "| 🧩 Name | 📝 Description | 🏷️ Classification |"
$c = $c.Replace($sec2OldHdr, $sec2NewHdr)
$sec2OldHdr2 = "| ---------------------- | ----------------------------------------------------------------------------------------------------------- | -------------- |"
$c = $c.Replace($sec2OldHdr2, "| --- | --- | --- |")

$sec2OldHdr3 = "| Name                      | Description                                                                                                                       | Classification |"
$c = $c.Replace($sec2OldHdr3, "| 🗃️ Name | 📝 Description | 🏷️ Classification |")
$c = $c.Replace(
    "| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                    | Description                                                                                                   | Classification |",
    "| 🗄️ Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ----------------------- | ------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                         | Description                                                                                              | Classification |",
    "| 🔄 Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ---------------------------- | -------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                         | Description                                                                                                            | Classification |",
    "| ⚡ Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                        | Description                                                                                                                                                                               | Classification |",
    "| 🏛️ Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                               | Description                                                                                                                           | Classification |",
    "| ✅ Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                           | Description                                                                                                                             | Classification |",
    "| 🌟 Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                             | Description                                                                                                                              | Classification |",
    "| 🔀 Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                          | Description                                                                                                | Classification |",
    "| 📜 Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ----------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

$c = $c.Replace(
    "| Name                            | Description                                                                                                                         | Classification |",
    "| 🔐 Name | 📝 Description | 🏷️ Classification |"
)
$c = $c.Replace(
    "| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 3 — Data Classification Taxonomy header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Classification   | Definition                                                              | Examples in This Repository                                         |",
    "| 🏷️ Classification | 📝 Definition | 💼 Examples in This Repository |"
)
$c = $c.Replace(
    "| ---------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 3 — Core Data Principles: remove Implementation Evidence + Source File
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Principle                         | Statement                                                                                              | Implementation Evidence                                                          | Source File                         |",
    "| 💡 Principle | 📝 Statement |"
)
$c = $c.Replace(
    "| --------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- | ----------------------------------- |",
    "| --- | --- |"
)
# Remove trailing | Evidence | Source File | cells from data rows
$c = $c.Replace(" | Bicep `@export()` type system with strongly typed interfaces                     | src/shared/common-types.bicep:1-155 |", " |")
$c = $c.Replace(" | `diagnosticSettings` resource with allLogs + allMetrics in all modules           | src/core/apim.bicep:256-295         |", " |")
$c = $c.Replace(" | SystemAssigned identity on APIM, Log Analytics, API Center; @secure() on outputs | src/shared/constants.bicep:89-105   |", " |")
$c = $c.Replace(" | Reader for APIM, API Center Data Reader + Compliance Manager for API Center      | src/core/apim.bicep:218-245         |", " |")
$c = $c.Replace(" | 10-key tag schema applied via commonTags union in main.bicep                     | infra/settings.yaml:29-39           |", " |")
$c = $c.Replace(" | `generateUniqueSuffix()` based on subscription+RG+solution+location hash         | src/shared/constants.bicep:150-165  |", " |")

# ══════════════════════════════════════════════════════
# SECTION 4 — Storage Distribution header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Store                   | Type                         | SKU                   | Retention                              | Data Category                             | Ingestion Mode             |",
    "| 🗄️ Store | 📂 Type | 💰 SKU | ⏰ Retention | 📊 Data Category | 📥 Ingestion Mode |"
)
$c = $c.Replace(
    "| ----------------------- | ---------------------------- | --------------------- | -------------------------------------- | ----------------------------------------- | -------------------------- |",
    "| --- | --- | --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 4 — Quality Baseline header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Quality Dimension   | Current State                                               | Target State                                            | Gap                                    |",
    "| 📐 Quality Dimension | 📊 Current State | 🎯 Target State | ⚠️ Gap |"
)
$c = $c.Replace(
    "| ------------------- | ----------------------------------------------------------- | ------------------------------------------------------- | -------------------------------------- |",
    "| --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 4 — Governance Maturity table header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Level           | Criteria                                                                                                                        | Status                                                                       |",
    "| 📈 Level | 📋 Criteria | ✅ Status |"
)
$c = $c.Replace(
    "| --------------- | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 4 — Maturity Justification table header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Claimed Level | Actual Level | Missing Criteria                                                             | Action                                         |",
    "| 🎯 Claimed Level | 📊 Actual Level | ⚠️ Missing Criteria | 🔧 Action |"
)
$c = $c.Replace(
    "| ------------- | ------------ | ---------------------------------------------------------------------------- | ---------------------------------------------- |",
    "| --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 4 — Compliance Posture: remove Evidence + Source File columns
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Control                      | Status              | Evidence                                                  | Source File                                       |",
    "| 🛡️ Control | ✅ Status |"
)
$c = $c.Replace(
    "| ---------------------------- | ------------------- | --------------------------------------------------------- | ------------------------------------------------- |",
    "| --- | --- |"
)
$c = $c.Replace(" | `RegulatoryCompliance: ""GDPR""` in commonTags              | infra/settings.yaml:38                            |", " |")
$c = $c.Replace(" | Managed identity on all service principals                | src/shared/common-types.bicep:39-56               |", " |")
$c = $c.Replace(" | allLogs category in diagnostic settings                   | src/core/apim.bicep:270-285                       |", " |")
$c = $c.Replace(" | Location parameter; no hard constraint to specific region | infra/main.bicep:64                               |", " |")
$c = $c.Replace(" | No customer-managed key (CMK) reference in source         | Not detected                                      |", " |")
$c = $c.Replace(" | 90d default only; no formal policy                        | src/shared/monitoring/insights/main.bicep:130-135 |", " |")
$c = $c.Replace(" | Not addressed in IaC scope                                | Not detected                                      |", " |")

Write-Host "Sections 1-4 done"

# ══════════════════════════════════════════════════════
# SECTION 5 — All 11 subsection tables: remove Source File column, add emoji headers
# ══════════════════════════════════════════════════════

# 5.1 Data Entities header
$c = $c.Replace(
    "| Component              | Description                                                                                                                 | Classification | Storage      | Owner               | Retention    | Freshness SLA | Source Systems | Consumers                                                | Source File                           |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ------------ | ------------- | -------------- | -------------------------------------------------------- | ------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
# Remove Source File cells from 5.1 data rows
$c = $c.Replace(" | src/shared/common-types.bicep:89-109  |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:140-152 |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:73-82   |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:84-90   |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:130-138 |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:111-118 |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:39-47   |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:49-56   |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:58-66   |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:154-155 |", " |")

# 5.2 Data Models header
$c = $c.Replace(
    "| Component                 | Description                                                                                                                                                                               | Classification | Storage      | Owner               | Retention    | Freshness SLA | Source Systems         | Consumers                                                            | Source File                         |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ------------ | ------------- | ---------------------- | -------------------------------------------------------------------- | ----------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/common-types.bicep:1-155 |", " |")
$c = $c.Replace(" | infra/settings.yaml:1-70            |", " |")
$c = $c.Replace(" | infra/main.bicep:90-95              |", " |")

# 5.3 Data Stores header
$c = $c.Replace(
    "| Component               | Description                                                                                                                                                    | Classification | Storage        | Owner               | Retention                     | Freshness SLA | Source Systems                      | Consumers                               | Source File                                          |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------- | ------------------- | ----------------------------- | ------------- | ----------------------------------- | --------------------------------------- | ---------------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/monitoring/operational/main.bicep:155-190 |", " |")
$c = $c.Replace(" | src/shared/monitoring/operational/main.bicep:135-155 |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:1-200      |", " |")
$c = $c.Replace(" | src/inventory/main.bicep:85-140                      |", " |")

# 5.4 Data Flows header
$c = $c.Replace(
    "| Component                    | Description                                                                                                                                                                  | Classification | Storage        | Owner               | Retention         | Freshness SLA | Source Systems       | Consumers                                       | Source File                                       |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------- | ------------------- | ----------------- | ------------- | -------------------- | ----------------------------------------------- | ------------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/core/apim.bicep:256-290                       |", " |")
$c = $c.Replace(" | src/core/apim.bicep:295-315                       |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:135-160 |", " |")
$c = $c.Replace(" | src/inventory/main.bicep:140-175                  |", " |")

# 5.5 Data Services header
$c = $c.Replace(
    "| Component                    | Description                                                                                                                                                                                      | Classification | Storage        | Owner               | Retention    | Freshness SLA | Source Systems         | Consumers                             | Source File                            |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- | -------------- | ------------------- | ------------ | ------------- | ---------------------- | ------------------------------------- | -------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/core/apim.bicep:160-215            |", " |")
$c = $c.Replace(" | src/inventory/main.bicep:85-115        |", " |")
$c = $c.Replace(" | src/core/developer-portal.bicep:80-200 |", " |")

# 5.6 Data Governance header
$c = $c.Replace(
    "| Component                  | Description                                                                                                                                                                                                                                      | Classification | Storage      | Owner               | Retention         | Freshness SLA | Source Systems                                | Consumers                                  | Source File                         |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- | ------------ | ------------------- | ----------------- | ------------- | --------------------------------------------- | ------------------------------------------ | ----------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | infra/settings.yaml:29-39           |", " |")
$c = $c.Replace(" | src/core/apim.bicep:218-245         |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:39-56 |", " |")
$c = $c.Replace(" | src/core/apim.bicep:256-290         |", " |")

# 5.7 Data Quality Rules header
$c = $c.Replace(
    "| Component                          | Description                                                                                                                                                                                   | Classification | Storage      | Owner               | Retention    | Freshness SLA | Source Systems                             | Consumers                                     | Source File                                       |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ------------ | ------------- | ------------------------------------------ | --------------------------------------------- | ------------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/core/apim.bicep:77-102                        |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:60-65   |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:130-135 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:55-60                  |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:150-165                |", " |")

# 5.8 Master Data header
$c = $c.Replace(
    "| Component                      | Description                                                                                                                                                                                                                   | Classification | Storage      | Owner               | Retention  | Freshness SLA | Source Systems                | Consumers                                     | Source File                        |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ---------- | ------------- | ----------------------------- | --------------------------------------------- | ---------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/constants.bicep:118-126 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:89-102  |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:105-116 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:65-80   |", " |")

# 5.9 Data Transformations header
$c = $c.Replace(
    "| Component                             | Description                                                                                                                                                                                  | Classification | Storage      | Owner               | Retention    | Freshness SLA | Source Systems                | Consumers                                                | Source File                        |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ------------ | ------------- | ----------------------------- | -------------------------------------------------------- | ---------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/constants.bicep:150-165 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:167-175 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:177-180 |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:182-200 |", " |")
$c = $c.Replace(" | src/core/apim.bicep:155-162        |", " |")

# 5.10 Data Contracts header
$c = $c.Replace(
    "| Component                     | Description                                                                                                                                                                                                 | Classification | Storage      | Owner               | Retention  | Freshness SLA | Source Systems        | Consumers                               | Source File                           |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ---------- | ------------- | --------------------- | --------------------------------------- | ------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/common-types.bicep:90-109  |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:130-138 |", " |")  # already done above but safe
$c = $c.Replace(" | src/shared/monitoring/main.bicep        |", " |")  # skip - this is a consumer, not source file col
$c = $c.Replace(" | src/shared/common-types.bicep:140-152 |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:154-155 |", " |")
$c = $c.Replace(" | infra/settings.yaml:1-70              |", " |")

# 5.11 Data Security header
$c = $c.Replace(
    "| Component                        | Description                                                                                                                                                                                                 | Classification | Storage      | Owner               | Retention    | Freshness SLA | Source Systems            | Consumers                      | Source File                                       |",
    "| 🔍 Component | 📝 Description | 🏷️ Classification | 💾 Storage | 👤 Owner | ⏰ Retention | ⚡ Freshness SLA | 📥 Source Systems | 📤 Consumers |"
)
$c = $c.Replace(
    "| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | ------------------- | ------------ | ------------- | ------------------------- | ------------------------------ | ------------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:190-200 |", " |")
$c = $c.Replace(" | src/core/apim.bicep:148-162                       |", " |")
$c = $c.Replace(" | src/core/apim.bicep:218-245                       |", " |")
$c = $c.Replace(" | src/core/apim.bicep:122-134                       |", " |")
$c = $c.Replace(" | infra/main.bicep:79-84                            |", " |")

Write-Host "Section 5 done"

# ══════════════════════════════════════════════════════
# SECTION 6 — ADR Summary header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| ID      | Title                                                      | Status   | Date     |",
    "| 🔖 ID | 📝 Title | ✅ Status | 📅 Date |"
)
$c = $c.Replace(
    "| ------- | ---------------------------------------------------------- | -------- | -------- |",
    "| --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 7 — Data Naming Conventions header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Standard                    | Rule                                                        | Example                        | Enforcement                               |",
    "| 📋 Standard | 📏 Rule | 💡 Example | 🔧 Enforcement |"
)
$c = $c.Replace(
    "| --------------------------- | ----------------------------------------------------------- | ------------------------------ | ----------------------------------------- |",
    "| --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 7 — Schema Design Standards header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Standard                       | Rule                                                                                           | Enforcement                                                                     |",
    "| 📋 Standard | 📏 Rule | 🔧 Enforcement |"
)
$c = $c.Replace(
    "| ------------------------------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 7 — Data Quality Standards header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Standard              | Rule                                                                                                                  | Enforcement                                                |",
    "| 📋 Standard | 📏 Rule | 🔧 Enforcement |"
)
$c = $c.Replace(
    "| --------------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |",
    "| --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 8 — Data Flow Patterns: remove Source File column
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Pattern Name                 | Flow Type            | Source               | Target                                                   | Processing                                               | Contract                       | Source File                                       |",
    "| 🔄 Pattern Name | 📊 Flow Type | 📥 Source | 📤 Target | ⚙️ Processing | 📜 Contract |"
)
$c = $c.Replace(
    "| ---------------------------- | -------------------- | -------------------- | -------------------------------------------------------- | -------------------------------------------------------- | ------------------------------ | ------------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- |"
)
$c = $c.Replace(" | infra/main.bicep:76                               |", " |")
$c = $c.Replace(" | src/shared/common-types.bicep:1-155               |", " |")
$c = $c.Replace(" | src/core/apim.bicep:256-290                       |", " |")
$c = $c.Replace(" | src/core/apim.bicep:295-315                       |", " |")
$c = $c.Replace(" | src/shared/monitoring/insights/main.bicep:135-160 |", " |")
$c = $c.Replace(" | src/inventory/main.bicep:140-175                  |", " |")

# ══════════════════════════════════════════════════════
# SECTION 8 — Producer-Consumer table header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Producer                      | Consumer                                                 | Data Type                  | Flow Type            | Contract                       | Integration Health                            |",
    "| 📤 Producer | 📥 Consumer | 📊 Data Type | 🔄 Flow Type | 📜 Contract | ✅ Integration Health |"
)
$c = $c.Replace(
    "| ----------------------------- | -------------------------------------------------------- | -------------------------- | -------------------- | ------------------------------ | --------------------------------------------- |",
    "| --- | --- | --- | --- | --- | --- |"
)

# ══════════════════════════════════════════════════════
# SECTION 9 — Access Control Model: remove Source File column
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Resource                | Role                               | Principal                       | Scope          | Source File                        |",
    "| 🔐 Resource | 👥 Role | 🤖 Principal | 🎯 Scope |"
)
$c = $c.Replace(
    "| ----------------------- | ---------------------------------- | ------------------------------- | -------------- | ---------------------------------- |",
    "| --- | --- | --- | --- |"
)
$c = $c.Replace(" | src/core/apim.bicep:218-245        |", " |")
$c = $c.Replace(" | src/inventory/main.bicep:155-175   |", " |")
$c = $c.Replace(" | src/shared/constants.bicep:118-120 |", " |")

# ══════════════════════════════════════════════════════
# SECTION 9 — Audit & Compliance table header
# ══════════════════════════════════════════════════════
$c = $c.Replace(
    "| Control                          | Type                   | Implementation                                                                                    | Status                                              |",
    "| 🛡️ Control | 📊 Type | 📝 Implementation | ✅ Status |"
)
$c = $c.Replace(
    "| -------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------- | --------------------------------------------------- |",
    "| --- | --- | --- | --- |"
)

Write-Host "All replacements done. New length: $($c.Length)"
[System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
Write-Host "File written successfully"
