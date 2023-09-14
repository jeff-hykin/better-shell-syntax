#!/usr/bin/env bash
case 'yes' in
    y*)
        echo y ;& # Fall through
    ye*)
        echo ye ;;& # Continue checking
    yes*)
        echo yes ;; # Stop here
    *)
        echo no ;; # Unreachable
esac
