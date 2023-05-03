#!/usr/bin/python3

import subprocess
import pathlib

test_file = pathlib.Path("shaders/pixilartifier.shader")

cmd = "uncrustify -c uncrustify.conf --update-config-with-doc"

import re

gg = re.compile(r"^\s*(?P<option>\w+)\s+=\s*(?P<value>.*?)(\s+#\s+(?P<possible_values>.*))?\s*$")

do_not_test = [

    'cmt_convert_tab_to_spaces',
    'cmt_cpp_to_c',
    'indent_cmt_with_tabs',
    'indent_func_call_param',
    'indent_paren_after_func_call',
    'indent_paren_after_func_decl',
    'indent_paren_after_func_def',
    'indent_paren_nl',
    'indent_vbrace_open_on_tabstop',
    'mod_full_brace_if_chain',
    'mod_full_brace_if_chain_only',
    'mod_remove_extra_semicolon',
    'newlines',
    'nl_before_if',
    'nl_before_return',
    'nl_brace_else',
    'nl_constr_colon',
    'nl_else_brace',
    'nl_else_if',
    'nl_elseif_brace',
    'nl_fdef_brace',
    'nl_for_brace',
    'nl_func_def_args',
    'nl_func_leave_one_liners',
    'nl_if_brace',
    'sp_after_assign',
    'sp_after_comma',
    'sp_after_sparen',
    'sp_arith',
    'sp_before_assign',
    'sp_before_semi_for',
    'sp_before_sparen',
    'sp_before_square',
    'sp_before_tr_emb_cmt',
    'sp_bool',
    'sp_brace_else',
    'sp_cmt_cpp_start',
    'sp_compare',
    'sp_cpp_cast_paren',
    'sp_else_brace',
    'sp_fparen_brace=add',
    'sp_incdec',
    'sp_inside_paren',
    'sp_inside_paren_cast',
    'sp_inside_sparen',
    'sp_inside_square',
    'sp_paren_paren',
    'sp_sign',
    'sp_sparen_brace',
    'string_escape_char',
    'utf8_bom',

]

#subprocess.run(["ip", "-o", "route"], capture_output=True, check=True).stdout.decode()
proc = subprocess.run(cmd.split(), capture_output=True, check=True, text=True)
for l in proc.stdout.splitlines():
    if l.startswith("#"):
        continue
    if not l.strip():
        continue

    option = gg.search(l).groupdict()

    if option['possible_values'] in ['string', 'number', 'unsigned number']:
        continue

    if option['option'] in do_not_test:
        continue

    if "/" in option['possible_values']:
        vals = [x for x in option['possible_values'].split("/") if x not in (option['value'], 'ignore')]
    else:
        print("skipping", option['option'], option['value'], option['possible_values'])
        continue

    for xy in vals:
        cmd = ['uncrustify', '-c', 'uncrustify.conf', '--set', f"{option['option']}={xy}", '--if-changed', '-q', '-f', test_file]
        ppp = subprocess.run(cmd, capture_output=True, check=True, text=True)

        if len(ppp.stdout) == 0:

            # If the option doesn't change this file, check the others;
            for other in pathlib.Path("shaders").glob("*.shader"):
                if other == test_file:
                    continue

                cmd = ['uncrustify', '-c', 'uncrustify.conf', '--set', f"{option['option']}={xy}", '--if-changed', '-q', '-f', other]
                lll = subprocess.run(cmd, capture_output=True, check=True, text=True)

                if len(lll.stdout) != 0:
                    print(f"{option['option']}={xy} altered {other} :: was {option['value']}")

        continue
        if len(ppp.stdout) == 0:
            continue

        import tempfile
        t = tempfile.NamedTemporaryFile('w', delete=False)
        t.write(ppp.stdout)
        t.close()

        print(f"{option['option']}={xy}")
        print(['diff', '-u', test_file, t.name])
        print(subprocess.run(['diff', '-u', test_file, t.name], capture_output=True, check=False, text=True).stdout)

    #diff -u shaders/Airsolid\ Glitch\ color\ 02.shader <(uncrustify -c uncrustify.conf --set mod_add_long_function_closebrace_comment=10 -f shaders/Airsolid\ Glitch\ color\ 02.shader --if-changed -q)
    continue
