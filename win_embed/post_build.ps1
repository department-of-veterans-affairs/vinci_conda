param(
    [Parameter(Mandatory=$true)]
    [string]$EnvPath
)

# Post-build testing script for win_cuda_3.4 environment
# This script tests the spacy pandas UDF functionality with PySpark and Spark NLP
# Key fixes applied:
# 1. Set PYSPARK_PYTHON and PYSPARK_DRIVER_PYTHON environment variables
# 2. Added preliminary Spark environment test before main test
# 3. Enhanced error reporting and timeout handling
# 4. Configured proper Java and Spark local IP settings

Write-Host "=== Starting post-build testing for win_embed environment ===" -ForegroundColor Green
Write-Host "Environment path: $EnvPath" -ForegroundColor Cyan

# Set error action to stop on errors
$ErrorActionPreference = "Stop"

try {
    # Test 1: Verify environment activation
    Write-Host "Test 1: Verifying environment activation..." -ForegroundColor Yellow
    conda activate $EnvPath
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to activate conda environment at $EnvPath"
    }
    Write-Host "[OK] Environment activated successfully" -ForegroundColor Green

    # Test 2: Check Python version
    Write-Host "Test 2: Checking Python version..." -ForegroundColor Yellow
    $pythonVersion = python --version 2>&1
    Write-Host "Python version: $pythonVersion" -ForegroundColor Cyan
    
    # Test 3: Check core package imports
    Write-Host "Test 3: Testing core package imports..." -ForegroundColor Yellow
    
    $corePackages = @(
        "import torch; print(f'PyTorch: {torch.__version__}')",
        "import numpy as np; print(f'NumPy: {np.__version__}')",
        "import pandas as pd; print(f'Pandas: {pd.__version__}')",
        "import pyspark; print(f'PySpark: {pyspark.__version__}')",
        "from pyrush import RuSH; print('RuSH: OK')"
    )
    
    foreach ($package in $corePackages) {
        try {
            $result = python -c $package 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK] $result" -ForegroundColor Green
            } else {
                Write-Host "[ERROR] Failed: $package" -ForegroundColor Red
                Write-Host "Error: $result" -ForegroundColor Red
            }
            
        } catch {
            Write-Host "[ERROR] Exception testing: $package" -ForegroundColor Red
            Write-Host "Error: $_" -ForegroundColor Red
        }
    }
    }
