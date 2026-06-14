# Muka Head Flux Tower Data Availability QC

## Project Overview

This repository documents the data availability and quality control checks conducted for the Muka Head flux tower GHG dataset from 2016 to 2025.

The main objective is to identify raw GHG file availability, potential file corruption, long-term data gaps, and missing biomet files before further EddyPro and flux data processing.

## Completed Work

- Raw GHG file download check
- EddyPro batch processing
- Fluxnet CSV generation
- Annual data organization
- Preliminary data availability assessment

## Identified Issues

| Issue | Period | Preliminary Diagnosis |
|---|---|---|
| Issue 1 | 2021-09-28 to 2022-01 | Potential raw GHG file corruption |
| Issue 2 | 2023-04 to 2023-11 | GHG files missing or seriously insufficient |
| Issue 3 | 2024-07-18 to 2025-04-08 | Extended GHG data gap |
| Issue 4 | 2021-03, 2023-10, 2023-11 | Missing biomet files in selected GHG archives |

## Scripts

| Script | Purpose |
|---|---|
| `01_GHG_Integrity_Check.sh` | Check potential GHG file corruption around 2021-09-28 |
| `02_GHG_Availability_Assessment.sh` | Count monthly GHG files from 2023-04 to 2023-11 |
| `03_GHG_Gap_Assessment.sh` | Assess the long-term GHG data gap from 2024-07 to 2025-04 |
| `04_Biomet_Completeness_Check.sh` | Check whether GHG archives contain biomet files |

## Working Directory

All QC outputs are stored under:

```bash
~/data/qc_check
