start = hslColor / hexColor
input = command _ ? ',' command / command
command = groupAction / numericAction
groupAction= 'bdc'/'bdw'/'bd'/'fs'/'cr'/'lh'/'tc'/'tc'/'tc'/'tc'/'c'/'f'/'o'/'n'/'v'
numericAction = _ combinedAction:combinedAction _ operator:operator* _ value:integer+ {
	const defaultOperator = '+'
	return {
    	combinedAction,
        operator: operator.length ? operator : defaultOperator,
        value: value.join('')
    }
}
hexColor = hex:'#' chars:(hexChar)* {
	if (chars.length === 3 || chars.length === 6) return hex + chars.join('')
    else return ''
}
hexChar = [A-Fa-f0-9]
hslColor = 'hsl(' _ hue:$(digit+) comma saturation:$(digit+) comma lightness:$(digit+) ')' {
    return {
        hue: Math.abs(hue),
        saturation,
        lightness
    }
}

comma = ','_
hue = [0-2]+[0-9]+[0-9] / [0-3]+[0-5]+[0-9] / '360'
combinedAction = [lrtbwhaxy]*
operator = [\/+\-*%#=]
integer = digits:[0-9]+ { return digits.join('') }
digit = [0-9]

// optional whitespace
_  = [ \t\r\n]*
// mandatory whitespace
__ = [ \t\r\n]+
