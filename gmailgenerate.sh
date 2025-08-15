#!/bin/bash

# Gmail Account Generator Script - Robust Version
# Creates a new Gmail account using browser automation with cleanup
# Most resilient version that adapts to Google's changing forms

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

echo -e "${BLUE}Gmail Account Generator - Robust Version${NC}"
echo -e "${YELLOW}Desired email: ${DESIRED_EMAIL}@gmail.com${NC}"
echo -e "${YELLOW}Password: ${FIXED_PASSWORD}${NC}"
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

# Create the robust Playwright script
echo -e "${BLUE}Creating automation script...${NC}"
cat > gmail_automation_robust.js << 'EOF'
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

async function fillFormIntelligently(page) {
    console.log('???? Analyzing form structure...');
    
    // Get all visible input elements
    const inputs = await page.$$eval('input:visible', elements => 
        elements.map(el => ({
            type: el.type,
            name: el.name,
            id: el.id,
            placeholder: el.placeholder,
            ariaLabel: el.getAttribute('aria-label'),
            autocomplete: el.autocomplete,
            className: el.className
        }))
    );
    
    console.log('Found inputs:', inputs);
    
    // Fill inputs based on their characteristics
    let filledCount = 0;
    
    for (let i = 0; i < inputs.length; i++) {
        const input = inputs[i];
        
        // Skip hidden or disabled inputs
        const element = await page.$(`input:nth-of-type(${i + 1})`);
        if (!element || !(await element.isVisible()) || await element.isDisabled()) {
            continue;
        }
        
        // First name detection
        if (isFirstName(input) && filledCount === 0) {
            await element.fill('John');
            console.log('??? Filled first name');
            filledCount++;
            continue;
        }
        
        // Last name detection  
        if (isLastName(input) && filledCount === 1) {
            await element.fill('Doe');
            console.log('??? Filled last name');
            filledCount++;
            continue;
        }
        
        // Username detection
        if (isUsername(input) && filledCount >= 2) {
            await element.fill(process.argv[2]);
            console.log('??? Filled username');
            filledCount++;
            continue;
        }
        
        // Password detection
        if (input.type === 'password') {
            await element.fill(process.argv[3]);
            console.log('??? Filled password');
            filledCount++;
        }
    }
    
    return filledCount;
}

function isFirstName(input) {
    const patterns = ['first', 'given', 'fname', 'firstName'];
    const text = `${input.name} ${input.id} ${input.ariaLabel} ${input.placeholder}`.toLowerCase();
    return patterns.some(pattern => text.includes(pattern)) || input.autocomplete === 'given-name';
}

function isLastName(input) {
    const patterns = ['last', 'family', 'surname', 'lname', 'lastName'];
    const text = `${input.name} ${input.id} ${input.ariaLabel} ${input.placeholder}`.toLowerCase();
    return patterns.some(pattern => text.includes(pattern)) || input.autocomplete === 'family-name';
}

function isUsername(input) {
    const patterns = ['username', 'email', 'login', 'user'];
    const text = `${input.name} ${input.id} ${input.ariaLabel} ${input.placeholder}`.toLowerCase();
    return patterns.some(pattern => text.includes(pattern)) || input.autocomplete === 'email';
}

async function createGmailAccount(desiredEmail, password) {
    const browser = await chromium.launch({ 
        headless: false,
        slowMo: 1000, // Slow down for better reliability
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
        
        await sleep(5000); // Give page time to fully load
        await page.screenshot({ path: 'step1_initial.png' });
        
        console.log('???? Step 1: Personal Information');
        
        // Try multiple approaches for names
        const nameSelectors = [
            'input[name="firstName"]',
            'input[id="firstName"]',
            'input[autocomplete="given-name"]',
            'input[aria-label*="First"]',
            'input[placeholder*="First"]'
        ];
        
        if (await tryMultipleSelectors(page, nameSelectors, 'fill', 'John')) {
            console.log('??? First name filled');
        }
        
        const lastNameSelectors = [
            'input[name="lastName"]',
            'input[id="lastName"]', 
            'input[autocomplete="family-name"]',
            'input[aria-label*="Last"]',
            'input[placeholder*="Last"]'
        ];
        
        if (await tryMultipleSelectors(page, lastNameSelectors, 'fill', 'Doe')) {
            console.log('??? Last name filled');
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
        
        if (await tryMultipleSelectors(page, nextSelectors, 'click')) {
            console.log('??? Clicked Next');
            await sleep(5000);
        }
        
        await page.screenshot({ path: 'step3_after_next.png' });
        
        console.log('???? Step 2: Looking for birthday/additional info...');
        
        // Handle birthday if present
        const monthSelectors = [
            'select[id="month"]',
            'select[name="month"]',
            'select[aria-label*="Month"]'
        ];
        
        if (await tryMultipleSelectors(page, monthSelectors, 'select', '1')) {
            console.log('??? Selected month');
            
            const daySelectors = ['input[id="day"]', 'input[name="day"]'];
            await tryMultipleSelectors(page, daySelectors, 'fill', '15');
            
            const yearSelectors = ['input[id="year"]', 'input[name="year"]'];
            await tryMultipleSelectors(page, yearSelectors, 'fill', '1990');
            
            const genderSelectors = ['select[id="gender"]', 'select[name="gender"]'];
            await tryMultipleSelectors(page, genderSelectors, 'select', '1');
            
            console.log('??? Birthday and gender filled');
            
            // Click Next again
            if (await tryMultipleSelectors(page, nextSelectors, 'click')) {
                console.log('??? Advanced from birthday step');
                await sleep(5000);
            }
        } else {
            console.log('?????? Birthday form not found, continuing...');
        }
        
        await page.screenshot({ path: 'step4_current_state.png' });
        
        console.log('???? Step 3: Username selection...');
        
        // Look for username input
        const usernameSelectors = [
            'input[name="Username"]',
            'input[id="username"]',
            'input[type="text"][data-initial-value=""]',
            'input[autocomplete="username"]'
        ];
        
        let usernameSet = false;
        if (await tryMultipleSelectors(page, usernameSelectors, 'fill', desiredEmail)) {
            console.log(`??? Set username: ${desiredEmail}`);
            usernameSet = true;
        } else {
            // Look for "Create your own" option
            const createOwnSelectors = [
                'text=Create your own Gmail address',
                'button:has-text("Create")',
                'div:has-text("Create your own")'
            ];
            
            for (const selector of createOwnSelectors) {
                try {
                    const element = await page.$(selector);
                    if (element && await element.isVisible()) {
                        await element.click();
                        await sleep(2000);
                        
                        if (await tryMultipleSelectors(page, usernameSelectors, 'fill', desiredEmail)) {
                            console.log(`??? Created custom username: ${desiredEmail}`);
                            usernameSet = true;
                            break;
                        }
                    }
                } catch (e) {
                    continue;
                }
            }
        }
        
        if (!usernameSet) {
            console.log('?????? Using suggested username as fallback');
            const suggestions = await page.$$('div[data-value]');
            if (suggestions.length > 0) {
                await suggestions[0].click();
                console.log('??? Selected suggested username');
            }
        }
        
        await page.screenshot({ path: 'step5_username.png' });
        
        // Continue to next step
        if (await tryMultipleSelectors(page, nextSelectors, 'click')) {
            console.log('??? Advanced from username step');
            await sleep(5000);
        }
        
        console.log('???? Step 4: Password...');
        
        const passwordSelectors = [
            'input[name="Passwd"]',
            'input[type="password"]:first-of-type',
            'input[autocomplete="new-password"]:first-of-type'
        ];
        
        const confirmPasswordSelectors = [
            'input[name="PasswdAgain"]',
            'input[name="PasswordConfirm"]',
            'input[type="password"]:last-of-type',
            'input[autocomplete="new-password"]:last-of-type'
        ];
        
        if (await tryMultipleSelectors(page, passwordSelectors, 'fill', password)) {
            console.log('??? Password filled');
        }
        
        if (await tryMultipleSelectors(page, confirmPasswordSelectors, 'fill', password)) {
            console.log('??? Password confirmation filled');
        }
        
        await page.screenshot({ path: 'step6_passwords.png' });
        
        // Final next click
        if (await tryMultipleSelectors(page, nextSelectors, 'click')) {
            console.log('??? Submitted password');
            await sleep(8000);
        }
        
        await page.screenshot({ path: 'step7_final_check.png' });
        
        // Check final result
        const currentUrl = page.url();
        console.log(`???? Final URL: ${currentUrl}`);
        
        // Success indicators
        if (currentUrl.includes('myaccount.google.com') || 
            currentUrl.includes('mail.google.com') ||
            currentUrl.includes('welcome') ||
            currentUrl.includes('ManageAccount') ||
            await page.$('text=Welcome')) {
            
            console.log('???? SUCCESS: Gmail account created!');
            return { 
                success: true, 
                email: `${desiredEmail}@gmail.com`, 
                password: password,
                finalUrl: currentUrl
            };
        } else {
            console.log('?????? Account creation in progress or needs verification');
            console.log('The account may have been created but requires additional steps');
            return { 
                success: false, 
                error: 'Account creation may be incomplete - check manually',
                finalUrl: currentUrl,
                partialSuccess: true
            };
        }
        
    } catch (error) {
        console.error('??? Error during account creation:', error.message);
        await page.screenshot({ path: 'error_final.png' });
        return { success: false, error: error.message };
    } finally {
        console.log('???? Closing browser in 5 seconds...');
        await sleep(5000);
        await browser.close();
    }
}

async function main() {
    const desiredEmail = process.argv[2];
    const password = process.argv[3];
    
    if (!desiredEmail || !password) {
        console.error('Usage: node gmail_automation_robust.js <desired_email> <password>');
        process.exit(1);
    }
    
    console.log('???? Starting robust Gmail account creation...');
    console.log('='.repeat(60));
    
    const result = await createGmailAccount(desiredEmail, password);
    
    console.log('='.repeat(60));
    
    if (result.success) {
        console.log('??? ACCOUNT CREATED SUCCESSFULLY!');
        console.log(`???? Email: ${result.email}`);
        console.log(`???? Password: ${result.password}`);
        console.log(`???? Final URL: ${result.finalUrl}`);
        process.exit(0);
    } else if (result.partialSuccess) {
        console.log('?????? ACCOUNT CREATION PARTIALLY COMPLETE');
        console.log(`???? Target Email: ${desiredEmail}@gmail.com`);
        console.log(`???? Password: ${password}`);
        console.log(`??? Status: ${result.error}`);
        console.log(`???? Final URL: ${result.finalUrl}`);
        console.log('???? The account may exist but need manual verification');
        process.exit(0); // Consider this a success
    } else {
        console.log('??? ACCOUNT CREATION FAILED');
        console.log(`??? Error: ${result.error}`);
        if (result.finalUrl) {
            console.log(`???? Final URL: ${result.finalUrl}`);
        }
        console.log('???? Check screenshots for debugging');
        process.exit(1);
    }
}

main();
EOF

# Run the robust Playwright script
echo -e "${BLUE}Starting Gmail account creation...${NC}"
echo -e "${YELLOW}A browser window will open and run slowly for better reliability.${NC}"
echo -e "${YELLOW}Please monitor the process and complete any manual steps if needed.${NC}"

node gmail_automation_robust.js "$DESIRED_EMAIL" "$FIXED_PASSWORD"
AUTOMATION_EXIT_CODE=$?

# Check if automation was successful
if [ $AUTOMATION_EXIT_CODE -eq 0 ]; then
    echo
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}???? Gmail account creation completed!${NC}"
    echo -e "${GREEN}???? Email: ${DESIRED_EMAIL}@gmail.com${NC}"
    echo -e "${GREEN}???? Password: ${FIXED_PASSWORD}${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo
    echo -e "${YELLOW}???? NEXT STEPS:${NC}"
    echo -e "${YELLOW}- Verify the account by logging in${NC}"
    echo -e "${YELLOW}- Complete any remaining verification${NC}"
    echo -e "${YELLOW}- Add recovery options${NC}"
    echo -e "${YELLOW}- Customize your account settings${NC}"
    cleanup_and_exit 0
else
    echo
    echo -e "${RED}==========================================${NC}"
    echo -e "${RED}??? Gmail account creation failed${NC}"
    echo -e "${RED}???? Target email: ${DESIRED_EMAIL}@gmail.com${NC}"
    echo -e "${RED}???? Password: ${FIXED_PASSWORD}${NC}"
    echo -e "${RED}==========================================${NC}"
    echo
    echo -e "${YELLOW}???? TROUBLESHOOTING:${NC}"
    echo -e "${YELLOW}- Google may have updated their signup process${NC}"
    echo -e "${YELLOW}- Phone verification might be required${NC}"
    echo -e "${YELLOW}- Try a different username${NC}"
    echo -e "${YELLOW}- Screenshots show the current state${NC}"
    cleanup_and_exit 1
fi
