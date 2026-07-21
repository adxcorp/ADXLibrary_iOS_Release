#!/bin/bash

set -e
set -o pipefail

########################################
# Utils
########################################
run_command() {
    local CMD="$1"
    local STRICT="${2:-false}"
    local answer

    echo ""
    echo "Execute this command?"
    echo "$CMD"

    if [[ "$STRICT" == "strict" ]]; then
        read -p "(y/n) [explicit y required]: " answer
    else
        read -t 10 -p "(y/n) [auto-run in 10s if no input]: " answer || true
        [[ -z "$answer" ]] && answer="y"
    fi

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo "[RUN]"
        eval "$CMD" || {
            echo "[ERROR] Command failed:"
            echo "$CMD"
            exit 1
        }
    else
        echo "[SKIP]"
    fi
}

########################################
# Commands
########################################
COMMANDS=(
"pod repo push ADXLibrary ADXLibrary-Core.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Domain.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-AdPie.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-AppLovin.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-AdMob.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Fyber.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Cauly.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Tnk.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Moloco.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-FBAudienceNetwork.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Pangle.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-UnityAds.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Mintegral.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-Yandex.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-LiftOff.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-PubMatic.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-InMobi.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary-BidMachine.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo update"
"pod spec lint ADXLibrary.podspec --sources='https://github.com/adxcorp/ADXLibrary_iOS_Release.git, https://github.com/CocoaPods/Specs.git' --allow-warnings --verbose --skip-import-validation --use-libraries"
"pod repo push ADXLibrary ADXLibrary.podspec --allow-warnings --verbose --skip-import-validation --use-libraries"
)

########################################
# Main
########################################
for CMD in "${COMMANDS[@]}"; do
    if [[ "$CMD" == "pod repo update"* || "$CMD" == "pod spec lint"* ]]; then
        run_command "$CMD"
    else
        run_command "$CMD" "strict"
    fi
done

echo ""
echo "✅ Done"