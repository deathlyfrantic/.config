if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -ne '%{\e[0m%}'
    echo -ne '['
    echo -ne '%{\e[32;1m%}'
    echo -ne $(basename $VIRTUAL_ENV)
    echo -ne  '%{\e[0m%}'
    echo -ne ']'
    echo -ne ' %{\e[30;1m%}::'
    echo -ne '%{\e[0m%} '
fi
