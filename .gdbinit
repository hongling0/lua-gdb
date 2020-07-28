define pl
    if $argc<1
        printf "need lua_State\n"
    else
        set $L=$arg0
        set $base_ci = &($L->base_ci)
        set $cur_ci=$L->ci
        set $cur_fr = 0
        while $base_ci!=$cur_ci
            set $cur_cl=((union GCUnion*)$cur_ci->func->val->value_.gc).cl
            set $is_lua=!($cur_ci->callstatus&(1<<1))
            set $cur_fr = $cur_fr+1
            if $is_lua
                set $cur_proto=$cur_cl.l.p
                set $file_name=(const char*)$cur_proto->source+sizeof(TString)
                set $cur_pc=(int)($cur_ci->u.l.savedpc-$cur_proto->code-1)
                set $cur_line=-1
                
                if $cur_proto->lineinfo
                    set $base_pc = -1
                    set $base_line=$cur_proto->linedefined
                    if $cur_proto->sizeabslineinfo == 0 || $cur_pc < $cur_proto->abslineinfo[0].pc    
                        
                    else
                        if $cur_pc >= $cur_proto->abslineinfo[$cur_proto->sizeabslineinfo - 1].pc
                            set $v_i = $cur_proto->sizeabslineinfo - 1
                        else
                            set $v_j = $cur_proto->sizeabslineinfo - 1
                            set $v_i = 0
                            while $v_i < $v_j - 1
                                set $v_m = ($v_j + $v_i) / 2
                                if $cur_pc >= $cur_proto->abslineinfo[$v_m].pc
                                    set $v_i = $v_m
                                else
                                    set $v_j = $v_m
                                end
                            end
                        end
                        set $base_pc = $cur_proto->abslineinfo[$v_i].pc
                        set $base_line=$cur_proto->abslineinfo[$v_i].line
                    end
                    while $base_pc < $cur_pc
                        set $base_pc=$base_pc+1
                        set $base_line = $base_line+$cur_proto->lineinfo[$base_pc]
                    end
                    set $cur_line=$base_line
                end
                printf "%d %s:%d\n",$cur_fr,$file_name,$cur_line
            else
                printf "%d ",$cur_fr
                print $cur_cl.c.f
            end
            set $cur_ci=$cur_ci->previous
        end
    end
end
document pl
    traceback with lua5.4
    https://github.com/hongling0/lua-gdb.git
end