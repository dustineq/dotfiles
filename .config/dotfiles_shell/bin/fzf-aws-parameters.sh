#!/bin/sh
aws_profiles=""

# Parse optional --aws-profile parameter
while [ $# -gt 0 ]; do
    case "$1" in
        --aws-profiles)
            aws_profiles="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -n "$aws_profile" ]; then
    aws_profile_param="--profile $aws_profile"
fi

mkdir -p ~/.cache/dotfiles_shell

foo () {
    echo "foo"
    echo "bar"
    echo "baz"
}

# cmd='aws ssm describe-parameters --query "Parameters[].Name" --output json | jq '.[]' -- /bin/sh -c' fzf \
cmd='/Users/dustin/Source/github.com/dustinvenegas/dotfiles/.config/dotfiles_shell/bin/fzf-aws-profile.sh' fzf \
    --bind 'start:reload:$cmd -- /bin/bash' \
    --bind 'ctrl-r:reload:$cmd -- /bin/bash' \
    --prompt "SSM - $AWS_PROFILE> "