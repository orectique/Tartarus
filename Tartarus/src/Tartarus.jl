module Tartarus

    upTheHill(corpus)
        h = match(r"(?<=\(≧◡≦\))([\s\S]*)(?=\(≧◡≦\*\))", corpus)
            
        if h === nothing
            println("The script $loc does not contain a valid character set definition.")
            return
        else
            h = h.captures[1]
        end
        
        KeysSus = [only(UTF32String[i])[1] for i in collect(split(h, "", keepempty=true))]
        KeysSus = Set(KeysSus)
        length(KeysSus) == 8 || error("$KeysSus is an invalid character set.")

        code = match(r"(?<=\(≧◡≦\*\))([\s\S]*)", corpus).captures[1];

        code = utf32(code);

        try
            global state = 0
            global memory = DefaultDict{Int, Int}(0)
        
            stateInc() = global state+= 1
            stateDec() = global state-= 1
        
            memInc() = global memory[state] += 1
            memDec() = global memory[state] -= 1
        
            input() = global memory[state] = Int(read(stdin, 1))
            output() = print(stdout, Char(memory[state]))
            
            global ptr = 1
        
            function execute(code)
                ptrs = Dict{Int, Int}()
                stack = Int[]
                for (lptr, bit) in enumerate(code)
                    if bit == KeysSus[7] 
                        push!(stack, lptr)
                    end
                    if bit == KeysSus[8]
                        if isempty(stack)
                            code = code[1:lptr]
                            break
                        end
                        sptr = pop!(stack)
                        ptrs[lptr], ptrs[sptr] = sptr, lptr
                    end
                end
        
                if !isempty(stack)
                    error("Loop not closed at $stack")
                end
        
                while ptr <= length(code)
                    
                    bit = code[ptr]
                    if bit == KeysSus[1] stateInc()
                    elseif bit == KeysSus[2] stateDec()
                    elseif bit == KeysSus[3] memInc()
                    elseif bit == KeysSus[4] memDec()
                    elseif bit == KeysSus[5] input()
                    elseif bit == KeysSus[6] output()
                    elseif (bit == KeysSus[7] && memory[state] == 0) || (bit == KeysSus[8] && memory[state] != 0) global ptr = ptrs[ptr]
                    end
                    
                    global ptr += 1
                end
            end
        
            execute(code)
        catch e
            println(e)
        end
    end
end # module Tartarus
