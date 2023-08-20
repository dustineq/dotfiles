#!/bin/sh

setEQEnv () {
    if [ -n "$1" ]; then
        export EQ_ENV="$1"
    fi

    if [ -z "$EQ_ENV" ]; then
        echo "EQEnv is required and not current set. "
        return 1
    fi

    export AWS_PROFILE="$EQ_ENV"

    # Create a copy of the main config when one does not exist.
    f="$HOME/.kube/config.$EQ_ENV"
    if [ ! -f "$f" ]; then
        cp "$HOME/.kube/config" "$f"
    fi
    export KUBECONFIG="$HOME/.kube/config.$EQ_ENV"

    # Shell specific.
    if [ "$(basename "$SHELL")" = "zsh" ]; then
        HISTFILE=~/.zsh_history.$EQ_ENV
    fi
}

fzfSetEQEnv () {
    pval=$(aws configure list-profiles | grep eq- | fzf -1)

    if [ -n "$pval" ]; then
        echo "Setting EQEnv to $pval"
        setEQEnv "$pval"

        if ! aws sts get-caller-identity > /dev/null; then
            echo 'No AWS Session - login with ''aws sso login'''
        fi
    fi
}

# Set EQENV is the variable is set.
if [ -n "$EQ_ENV" ]; then
    setEQEnv
fi