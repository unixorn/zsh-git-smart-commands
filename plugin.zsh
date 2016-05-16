function git-smart-commit() {
    if [ $# -eq 0 ]; then
        git commit -v
    else
        local flags=()

        if [ "$(git status --porcelain | cut -b1 | awk '$1')" = "" ]; then
            git add -A
            git status -s
        fi

        while grep -q "^-" <<< "$1"; do
            flags+=("$1")
            shift
        done

        local message="$(echo "${@}")"
        if [ ${#message} -ge 50 ]; then
            flags+=(-e)
        fi

        git commit "${flags[@]}" -m "$message"
    fi
}

function git-smart-add() {
    if [ $# -eq 0 ]; then
        git add .
    else
        git add "${@}"
    fi
}

function git-smart-push() {
    local branch_name=$(git symbolic-ref --short HEAD)

    if ! git config branch.$branch_name.remote >&-; then
        if [ $# -eq 1 ]; then
            PUSH_FLAGS=(--set-upstream) _push-to-or-origin "${@}" $branch_name
        else
            PUSH_FLAGS=(--set-upstream) _push-to-or-origin "${@}"
        fi
    else
        _push-to-or-origin "${@}"
    fi
}

function _push-to-or-origin() {
    local custom_origin="$1"
    shift

    if git remote show -n | grep -qF "$custom_origin"; then
        git push $PUSH_FLAGS "$custom_origin" "${@}"
    else
        git push $PUSH_FLAGS origin "${@}"
    fi
}

function git-smart-pull() {
    if [ "$(git status -s)" ]; then
        git stash -u
        git pull "${@}"
        git stash pop
    else
        git pull "${@}"
    fi

    git submodule init
    git submodule update
}

function git-smart-remote() {
    if [ "$(git remote show -n)" ]; then
        git remote "${@}"
    else
        git remote add origin "${@}"
    fi
}
