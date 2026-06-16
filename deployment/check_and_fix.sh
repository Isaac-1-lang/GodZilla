#!/bin/bash
# Check VPS setup and fix issues

VPS_USER="emg32"
VPS_HOST="157.173.101.159"
VPS_PORT="24032"

echo "================================================"
echo "  Checking VPS Setup"
echo "================================================"

ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'EOF'

echo "Current directory:"
pwd

echo ""
echo "Checking godzilla directory structure:"
ls -la ~/godzilla/

echo ""
echo "Checking web directory:"
ls -la ~/godzilla/web/

echo ""
echo "Checking if dashboard.html exists:"
if [ -f ~/godzilla/web/dashboard.html ]; then
    echo "✓ dashboard.html found"
else
    echo "✗ dashboard.html NOT found"
fi

EOF

echo ""
echo "================================================"
echo "Fix: Re-uploading dashboard.html..."
echo "================================================"
scp -P $VPS_PORT ../web/dashboard.html $VPS_USER@$VPS_HOST:/home/emg32/godzilla/web/

echo ""
echo "Verifying upload..."
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST "ls -lh ~/godzilla/web/dashboard.html"

echo ""
echo "================================================"
echo "Done! Now access:"
echo "http://157.173.101.159:8083/dashboard.html"
echo "================================================"
