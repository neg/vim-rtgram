vim9script noclear
# SPDX-License-Identifier: GPL-3.0-only
var save_cpo = &cpo
set cpo&vim

highlight default link RTGramIssuMatch SpellCap

def GenPattern(text: string, start: number, length: number): string
	def Sanitize(str: string): string
		return substitute(escape(str, "'\\"), ' ', '\\_\\s', 'g')
	enddef

	# The context from languagetool might be {pre,post}pended with
	# three dots (...), remove them and adjust the start offset of
	# thr error to match the change.
	var context = substitute(text, '^\.\.\.', '', '')
	var offset = start - (len(text) - len(context))
	context = substitute(context, '\.\.\.$', '', '')

	var prefix = Sanitize(offset > 0 ? context[: offset - 1] : '')
	var error = Sanitize(context[offset : offset + length - 1])
	var postfix = Sanitize(context[offset + length :])

	return '\V' .. prefix .. '\zs' .. error .. '\ze' .. postfix
enddef

def ParseJson(data: string, lines: list<string>): list<dict<any>>
	def Offset2Position(offset: number): dict<number>
		var lnum = 0
		var count = 0

		for line in lines
			var add = strchars(line) + 1
			lnum += 1
			if count + add > offset
				break
			endif
			count += add
		endfor

		return {line: lnum, col: offset - count}
	enddef

	var errors = []
	for issue in json_decode(data).matches
		var error = {
			pos: Offset2Position(issue.offset),
			pattern: GenPattern(issue.context.text, issue.context.offset, issue.context.length),
			info: issue.message .. ' [' ..  issue.rule.category.id .. ', ' .. issue.rule.id .. ']',
		}
		call errors->add(error)
	endfor
	return errors
enddef

export def Reset()
	# Remove highlights
	for m in filter(getmatches(), 'v:val.group ==# "RTGramIssuMatch"')
		matchdelete(m.id)
	endfor

	# Remove virtual text
	if len(prop_type_get('rtgramissue')) != 0
		prop_remove({type: 'rtgramissue', all: true})
		prop_type_delete('rtgramissue')
	endif

	prop_type_add('rtgramissue', {highlight: 'ModeMsg'})
enddef

export def Check()
	Reset()
	var lines = getline(1, "$")

	echomsg 'Grammar check running...'
	var cmd = printf('languagetool --clean-overlapping --encoding %s --language %s --json -', &encoding, &spelllang)
	var data = system(cmd .. ' 2> /dev/null', lines)
	if v:shell_error != 0 || len(data) == 0
		echomsg 'Grammar check failed ' .. (v:shell_error != 0 ? 'with exit code ' .. v:shell_error : 'no data')
		return
	endif

	var issues = ParseJson(data, lines)
	for issue in issues
		matchadd('RTGramIssuMatch', issue.pattern, 999)

		prop_add(issue.pos.line, 0, {
			text_padding_left: issue.pos.col,
			text_align: 'below',
			type: 'rtgramissue',
			text:  '└─ ' .. issue.info,
		})
	endfor

	redraw!
	echomsg 'Grammar check found ' .. len(issues) .. ' grammatical issues'
enddef

&cpo = save_cpo
