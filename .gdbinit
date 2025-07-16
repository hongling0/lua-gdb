define pl
    if $argc<1
        printf "need lua_State\n"
    else
        set $L=$arg0
        set $base_ci = &($L->base_ci)
        set $current_ci=$L->ci
        while $base_ci!=$current_ci
            set $current_cl=((union GCUnion*)$current_ci->func->p.val.value_.gc).cl
            set $islua=$current_ci->callstatus&(1<<1)
            if $islua
                set $proto=$current_cl.l.p
                set $name=(const char*)$proto->source+sizeof(TString)
                set $current_pc=$current_ci->u.l.savedpc-$proto->code-1
                set $line=$proto->lineinfo?$proto->lineinfo[$current_pc]:-1
                printf "%s:%d\n",$name,$line
            else
                print $current_cl.c.f
            end
            set $current_ci=$current_ci->previous
        end
    end
end
document pl
    traceback with lua5.3
    https://github.com/hongling0/lua-gdb.git
end
