#!/bin/bash

# Gmail Account Generator Script - Manual Takeover Version
# Creates a new Gmail account using browser automation with cleanup
# Stops at birthday section for manual completion

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Check if required commands exist
if ! command_exists node; then
    echo -e "${RED}Error: Node.js is not installed. Please install Node.js and try again.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}Error: npm is not installed. Please install npm and try again.${NC}"
    exit 1
fi

# Store the current directory to return to it later
ORIGINAL_DIR=$(pwd)

# Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')
WORK_DIR="$TEMP_DIR/gmail_generator_$(date +%s)"

# Function to cleanup and exit
cleanup_and_exit() {
    local exit_code=$1
    echo -e "${YELLOW}Cleaning up temporary files...${NC}"
    cd "$ORIGINAL_DIR"
    if [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR" 2>/dev/null
    fi
    exit $exit_code
}

# Trap to ensure cleanup happens even if script is interrupted
trap 'cleanup_and_exit 1' INT TERM

# Check if email argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide the desired Gmail address as an argument.${NC}"
    echo -e "${YELLOW}Usage: $0 desired.email.address${NC}"
    echo -e "${YELLOW}Example: $0 johndoe123${NC}"
    echo -e "${YELLOW}Note: @gmail.com will be added automatically${NC}"
    exit 1
fi

DESIRED_EMAIL="$1"
FIXED_PASSWORD="GODstf@123"

echo -e "${BLUE}Gmail Account Generator - Manual Takeover Version${NC}"
echo -e "${YELLOW}Desired email: ${DESIRED_EMAIL}@gmail.com${NC}"
echo -e "${YELLOW}Password: ${FIXED_PASSWORD}${NC}"
echo -e "${YELLOW}Will stop at birthday section for manual completion${NC}"
echo

# Create temporary working directory
echo -e "${BLUE}Setting up temporary workspace...${NC}"
mkdir -p "$WORK_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to create temporary directory.${NC}"
    exit 1
fi

cd "$WORK_DIR"

# Initialize npm project and install playwright
echo -e "${BLUE}Installing Playwright for browser automation...${NC}"
npm init -y > /dev/null 2>&1
npm install playwright > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install Playwright.${NC}"
    cleanup_and_exit 1
fi

# Install Playwright browsers
echo -e "${BLUE}Installing browser binaries...${NC}"
npx playwright install chromium > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install browser binaries.${NC}"
    cleanup_and_exit 1
fi

# Create the manual takeover Playwright script
echo -e "${BLUE}Creating automation script...${NC}"
cat > gmail_automation_manual.js << 'EOF'
const { chromium } = require('playwright');

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function tryMultipleSelectors(page, selectors, action = 'click', value = null, timeout = 3000) {
    for (const selector of selectors) {
        try {
            console.log(`Trying selector: ${selector}`);
            const element = await page.waitForSelector(selector, { timeout });
            
            if (element && await element.isVisible()) {
                if (action === 'click') {
                    await element.click();
                } else if (action === 'fill' && value !== null) {
                    await element.fill(value);
                } else if (action === 'select' && value !== null) {
                    await element.selectOption(value);
                }
                console.log(`??? Success with selector: ${selector}`);
                return true;
            }
        } catch (e) {
            console.log(`??? Failed with selector: ${selector} - ${e.message}`);
            continue;
        }
    }
    return false;
}

async function createGmailAccountPartial(desiredEmail, password) {
    const browser = await chromium.launch({ 
        headless: false,
        slowMo: 200, // Faster than robust version
        args: [
            '--no-sandbox', 
            '--disable-dev-shm-usage',
            '--disable-blink-features=AutomationControlled',
            '--start-maximized'
        ]
    });
    
    const context = await browser.newContext({
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        viewport: { width: 1920, height: 1080 }
    });
    
    const page = await context.newPage();
    
    try {
        console.log('???? Opening Google accounts page...');
        await page.goto('https://accounts.google.com/signup/v2/createaccount?flowName=GlifWebSignIn&flowEntry=SignUp', {
            waitUntil: 'domcontentloaded',
            timeout: 45000
        });
        
        await sleep(3000);
        await page.screenshot({ path: 'step1_initial.png' });
        
        console.log('???? Step 1: Filling Personal Information...');
        
        // Try multiple approaches for names - faster timeout
        const nameSelectors = [
            'input[name="firstName"]',
            'input[id="firstName"]',
            'input[autocomplete="given-name"]',
            'input[aria-label*="First"]',
            'input[placeholder*="First"]'
        ];
        
        if (await tryMultipleSelectors(page, nameSelectors, 'fill', 'John', 2000)) {
            console.log('??? First name filled');
        } else {
            console.log('?????? Could not fill first name - you may need to do this manually');
        }
        
        const lastNameSelectors = [
            'input[name="lastName"]',
            'input[id="lastName"]', 
            'input[autocomplete="family-name"]',
            'input[aria-label*="Last"]',
            'input[placeholder*="Last"]'
        ];
        
        if (await tryMultipleSelectors(page, lastNameSelectors, 'fill', 'Doe', 2000)) {
            console.log('??? Last name filled');
        } else {
            console.log('?????? Could not fill last name - you may need to do this manually');
        }
        
        await page.screenshot({ path: 'step2_names_filled.png' });
        
        // Click Next
        const nextSelectors = [
            'button:has-text("Next")',
            'div[role="button"]:has-text("Next")',
            'button[type="submit"]',
            '.VfPpkd-LgbsSe:has-text("Next")',
            'span:has-text("Next")'
        ];
        
        if (await tryMultipleSelectors(page, nextSelectors, 'click', null, 2000)) {
            console.log('??? Clicked Next');
            await sleep(3000);
        } else {
            console.log('?????? Could not click Next automatically');
        }
        
        await page.screenshot({ path: 'step3_after_next.png' });
        
        console.log('???? Reached birthday section - STOPPING FOR MANUAL TAKEOVER');
        console.log('=' * 60);
        console.log('INSTRUCTIONS FOR MANUAL COMPLETION:');
        console.log('1. Fill in your birthday (use an age 18+ to avoid phone verification)');
        console.log('2. Select your gender');
        console.log('3. Click Next');
        console.log('4. Choose or create your username');
        console.log('5. Set your password (suggested: ' + password + ')');
        console.log('6. Complete any remaining steps');
        console.log('=' * 60);
        console.log('The browser will remain open for you to complete manually.');
        console.log('Press Ctrl+C in this terminal when you are done to cleanup.');
        
        // Keep the browser open and wait indefinitely
        console.log('Browser is now ready for manual completion...');
        
        // Wait for user to complete manually (or Ctrl+C)
        while (true) {
            await sleep(120000); // Check every 2 minutes
        }
    } catch (error) {
        if (error.message.includes('Target closed')) {
            console.log('Browser was closed by user - cleanup will proceed');
            return { success: false, error: 'User closed browser' };
        }
        console.error('??? Error during account creation:', error.message);
        await page.screenshot({ path: 'error_final.png' });
        return { success: false, error: error.message };
    } finally {
        console.log('???? Closing browser...');
        try {
            await browser.close();
        } catch (e) {
            // Browser might already be closed by user
        }
    }
}

async function main() {
    const desiredEmail = process.argv[2];
    const password = process.argv[3];
    
    if (!desiredEmail || !password) {
        console.error('Usage: node gmail_automation_manual.js <desired_email> <password>');
        process.exit(1);
    }
    
    console.log('???? Starting Gmail account creation (manual takeover)...');
    console.log('='.repeat(60));
    
    const result = await createGmailAccountPartial(desiredEmail, password);
    
    console.log('='.repeat(60));
    
    if (result.success) {
        console.log('??? ACCOUNT COMPLETED SUCCESSFULLY!');
        console.log(`???? Email: ${result.email}`);
        console.log(`???? Password: ${result.password}`);
        console.log(`???? Final URL: ${result.finalUrl}`);
        process.exit(0);
    } else {
        console.log('Session ended');
        if (result.error && !result.error.includes('User closed browser')) {
            console.log(`??? Error: ${result.error}`);
        }
        process.exit(0); // Don't consider manual completion an error
    }
}

main();
EOF

# Run the manual takeover script
echo -e "${BLUE}Starting Gmail account creation...${NC}"
echo -e "${YELLOW}The browser will open and stop at the birthday section.${NC}"
echo -e "${YELLOW}You can then complete the process manually.${NC}"
echo -e "${YELLOW}Press Ctrl+C when done to cleanup.${NC}"
echo

node gmail_automation_manual.js "$DESIRED_EMAIL" "$FIXED_PASSWORD"
AUTOMATION_EXIT_CODE=$?

# Cleanup message
echo
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}???? Session completed!${NC}"
echo -e "${GREEN}???? Target Email: ${DESIRED_EMAIL}@gmail.com${NC}"
echo -e "${GREEN}???? Password: ${FIXED_PASSWORD}${NC}"
echo -e "${GREEN}==========================================${NC}"
echo
echo -e "${YELLOW}???? If you successfully created the account:${NC}"
echo -e "${YELLOW}- Log into your new Gmail account to verify${NC}"
echo -e "${YELLOW}- Add recovery options for security${NC}"
echo -e "${YELLOW}- Customize your account settings${NC}"

cleanup_and_exit 0
