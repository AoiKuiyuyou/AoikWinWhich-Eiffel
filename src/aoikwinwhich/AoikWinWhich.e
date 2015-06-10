    --
class
    AOIKWINWHICH

create
    make

feature {NONE} -- Create

    make
        local
            exc: EXCEPTIONS
        do
            create exc
            exc.die (main)
        end

feature {NONE} -- Main

        -- 4zKrqsC
        -- Program entry

    main: INTEGER
        local
            args: ARGUMENTS_32
            prog: STRING_32
            exe_path_s: LIST [STRING_32]
        do
                --
            create args

                -- 9mlJlKg
                -- If not exactly one command argument is given
            if args.argument_count /~ 1 then
                    -- 7rOUXFo
                    -- Print program usage
                print ("[
Usage: aoikwinwhich PROG

#/ PROG can be either name or path
aoikwinwhich notepad.exe
aoikwinwhich C:\Windows\notepad.exe

#/ PROG can be either absolute or relative
aoikwinwhich C:\Windows\notepad.exe
aoikwinwhich Windows\notepad.exe

#/ PROG can be either with or without extension
aoikwinwhich notepad.exe
aoikwinwhich notepad
aoikwinwhich C:\Windows\notepad.exe
aoikwinwhich C:\Windows\notepad

]")

                    -- 3nqHnP7
                    -- Exit
                RESULT := 1
            else

                    -- 9m5B08H
                    -- Get executable name or path
                prog := args.argument (1)

                    -- 8ulvPXM
                    -- Find executable paths
                exe_path_s := find_exe_paths (prog)

                    -- 5fWrcaF
                    -- If has found none
                if exe_path_s.count = 0 then
                        -- 3uswpx0
                        -- Exit
                    RESULT := 2
                else
                        -- If has found some

                        -- 9xPCWuS
                        -- Print result
                    across
                        exe_path_s as exe_path_i
                    loop
                        print (exe_path_i.item + "%N")
                    end

                        -- 4s1yY1b
                        -- Exit
                    RESULT := 0
                end
            end
        end

feature {NONE}

        --

    proc_lc: STRING_32
            -- "lc" means lowercase.
            -- Initialized at 6pyGU6b, used at 2t8XU4N.
            -- Eiffel's agent function can not access function arguments and local variables,
            -- so have to use an instance field.

        --

    find_exe_paths (prog: STRING_32): LIST [STRING_32]
        local
            env: EXECUTION_ENVIRONMENT
            env_pathext: detachable STRING_32
            env_path: detachable STRING_32
            ext_s: LIST [STRING_32]
            dir_path_s: LINKED_LIST [STRING_32]
            prog_has_ext: BOOLEAN
            exe_path_s: LINKED_LIST [STRING_32]
            path: STRING_32
            path_2: STRING_32
            file: PLAIN_TEXT_FILE
        do

                --
            create env

                -- 6pyGU6b
            proc_lc := prog.as_lower

                -- 8f1kRCu
            env_pathext := env.item ("PATHEXT")

                -- 4fpQ2RB
            if env_pathext = Void then
                    -- 9dqlPRg
                    -- Return
                Result := create {LINKED_LIST [STRING_32]}.make
            else

                    -- 6qhHTHF
                    -- Split into a list of extensions
                ext_s := env_pathext.split (';')

                    -- 2pGJrMW
                    -- Strip
                across
                    ext_s as ext_i
                loop
                        -- Mutate the string
                    ext_i.item.left_adjust
                    ext_i.item.right_adjust
                end

                    -- 2gqeHHl
                    -- Remove empty.
                    -- Must be done after the stripping at 2pGJrMW.
                ext_s := list_filter (ext_s, (agent  (ext: STRING_32): BOOLEAN
                    do
                        Result := ext /= ""
                    end))

                    -- 2zdGM8W
                    -- Convert to lowercase
                ext_s.do_all ((agent  (ext: STRING_32)
                    do
                            -- Mutate the string
                        ext.to_lower
                    end))

                    -- 2fT8aRB
                    -- Uniquify
                ext_s := list_uniq (ext_s)

                    -- 4ysaQVN
                env_path := env.item ("PATH")

                    -- 5gGwKZL
                if env_path = Void then
                        -- 7bVmOKe
                        -- Go ahead with "dir_path_s" being empty
                    dir_path_s := create {LINKED_LIST [STRING_32]}.make
                else

                        -- 6mPI0lg
                        -- Split into a list of dir paths
                    dir_path_s := list_to_linked_list (env_path.split (';'))
                end

                    -- 5rT49zI
                    -- Insert empty dir path to the beginning.
                    --
                    -- Empty dir handles the case that "prog" is not a short name,
                    -- either relative or absolute. See code 7rO7NIN.
                dir_path_s.start
                dir_path_s.put_left ("")

                    -- 2klTv20
                    -- Uniquify
                dir_path_s := list_uniq (dir_path_s)

                    -- 9gTU1rI
                    -- Check if "prog" ends with one of the file extension in "ext_s".
                prog_has_ext := ext_s.there_exists ((agent  (ext: STRING_32): BOOLEAN
                    do
                            -- 2t8XU4N
                        Result := proc_lc.ends_with (ext)
                    end))

                    -- 6bFwhbv
                create exe_path_s.make
                across
                    dir_path_s as dir_path_i
                loop
                        -- 7rO7NIN
                        -- Synthesize a path
                    if dir_path_i.item.is_equal ("") then
                        path := prog
                    else
                        path := dir_path_i.item + "\" + prog
                    end

                        --
                    create file.make_with_name (path)

                        -- 6kZa5cq
                        -- If "prog" ends with executable file extension
                    if prog_has_ext then
                            -- 3whKebE
                        if file.access_exists then
                                -- 2ffmxRF
                            exe_path_s.finish
                            exe_path_s.put_right (path)
                        end
                    end

                        -- 2sJhhEV
                        -- Assume user has omitted the file extension
                    across
                        ext_s as ext_i
                    loop
                            -- 6k9X6GP
                            -- Synthesize a path with one of the file extensions in PATHEXT
                        path_2 := path + ext_i.item
                        create file.make_with_name (path_2)

                            -- 6kabzQg
                        if file.access_exists then
                                -- 7dui4cD
                            exe_path_s.finish
                            exe_path_s.put_right (path_2)
                        end
                    end
                end

                    -- 8swW6Av
                    -- Uniquify
                exe_path_s := list_uniq (exe_path_s)

                    -- 7y3JlnS
                Result := exe_path_s
            end
        end

feature {NONE} -- List util

        --

    list_filter (item_s: LIST [STRING_32]; predicate: FUNCTION [ANY, TUPLE [STRING_32], BOOLEAN]): LIST [STRING_32]
        local
            res: LINKED_LIST [STRING_32]
        do
                --
            create res.make

                --
            across
                item_s as i
            loop
                if predicate.item (i.item) then
                    res.finish
                    res.put_right (i.item)
                end
            end

                --
            Result := res
        end

        --

    list_has_item (item_s: LIST [STRING_32]; item: STRING_32): BOOLEAN
            -- Comparison is by value equality using "STRING_32.is_equal".
        do
            from
                RESULT := false
                item_s.start
            until
                item_s.exhausted
            loop
                if item_s.item.is_equal (item) then
                    RESULT := true
                    item_s.finish
                end
                item_s.forth
            end
        end

        --

    list_uniq (item_s: LIST [STRING_32]): LINKED_LIST [STRING_32]
        local
            item_s_uniq: LINKED_LIST [STRING_32]
        do
                --
            create item_s_uniq.make

                --
            across
                item_s as item_i
            loop
                    -- `item_s_uniq.has(cur.item)` not works
                if not list_has_item (item_s_uniq, item_i.item) then
                    item_s_uniq.finish
                    item_s_uniq.put_right (item_i.item)
                end
            end

                --
            Result := item_s_uniq
        end

        --

    list_to_linked_list (item_s: LIST [STRING_32]): LINKED_LIST [STRING_32]
        do
                --
            create Result.make

                --
            across
                item_s as item_i
            loop
                Result.finish
                Result.put_right (item_i.item)
            end
        end

end
