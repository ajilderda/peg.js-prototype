{
    var tinycolor = require('tinycolor2');
    const isNotNullOrUndefined = (input) => input !== null && input !== undefined;
    const createFill = ({color, operator}) => {
      return {
        type: 'fill',
        operator: operator === '-' ? 'remove' : 'add',
        color
      }
    };

    function toRgb(value) {
      const color = tinycolor(value);
      return color.toRgb();
    }

    const rgbVal = (value) => {
      return value.includes('%') ? value * 255 : value;
    };

    const toUnit = (value, type = null) => {
      return {
        value, type
      }
    }

    const toOperation = (xywhArr, {value}, operator, defaultOperator = '=') => {
      return xywhArr.map(xywh => {
        const type = ((input) => {
          const xywh = input.toLowerCase();
          switch (xywh) {
            case 'x':
              return 'MOVE_X'
            case 'y':
              return 'MOVE_Y'
            case 'w':
              return 'WIDTH'
            case 'h':
              return 'HEIGHT'
          }
        })(xywh);

        return {
          type,
          operator,
          value,
          defaultOperator,
        }
      })
    }

}

// input = command _ ? ',' command / command
// command = groupAction / numericAction
// // Actions
// groupAction= 'bdc'/'bdw'/'bd'/'fs'/'cr'/'lh'/'tc'/'tc'/'tc'/'tc'/'c'/'f'/'o'/'n'/'v'
// numericAction = _ combinedAction:combinedAction _ operator:operator* _ value:integer+ {
// 	const defaultOperator = '+'
// 	return {
//     	combinedAction,
//         operator: operator.length ? operator : defaultOperator,
//         value: value.join('')
//     }
// }

// Colors
start = args:(action separator*)+ extraCharacters { return args.map((v) => v[0]) }
  /  action
action = fill / xywh
fill = F _ operator:plusOrMinus? _ color:color { return createFill({color, operator}) }
  / F color:color { return createFill({color}) }
  / color:color { return createFill({color}) }
xywh = xywh:XYWH _ operator:operator _ value:unit { return toOperation(xywh, value, operator) }
  / xywh:XYWH _ value:unit  { return toOperation(xywh, value, null, '=') }
unit = number:number type:px { return toUnit(number, type) }
  / number:number { return toUnit(number) }
pctUnit = number:number type:pct { return toUnit(number, type) }
pxOrPctUnit = pctUnit / unit

XYWH = [XxYyWwHh]+;
F = [Ff];
px = 'px'
pct = '%'

color = colorRGB / colorHSL / colorHex
colorHex = c:$('#' colorHex3 colorHex3?) {
    return toRgb(c);
}
colorHex3 = hexChar hexChar hexChar
colorRGB = ('rgba' / 'rgb') '(' _ r:numOrPercent ',' _ g:numOrPercent ',' _ b:numOrPercent ','? _ a:number? _ ')' {
    const alpha = isNotNullOrUndefined(a) ? a : 1;
    return toRgb(`rgba(${rgbVal(r)}, ${rgbVal(g)}, ${rgbVal(b)}, ${isNotNullOrUndefined(a) ? a : 1})`);
}
colorHSL = ('hsla' / 'hsl') '(' _ h:number ',' _ s:percentage ',' _ l:percentage ','? _ a:number? _ ')' {
    const alpha = isNotNullOrUndefined(a) ? a : 1;
    return toRgb(`hsla(${h}, ${s}, ${l}, ${alpha})`);
}

//  Generic
hexChar = [0-9a-fA-F]
numOrPercent = percentage / number
percentage = $(number '%')
number = $([0-9]+ ('.' [0-9]+)?)
plusOrMinus = '+' / '-'

// Misc
separator = _ '/' _ { return null }
combinedAction = [lrtbwhaxy]*
operator = [\/+\-*%#=]
integer = digits:[0-9]+ { return digits.join('') }
digit = [0-9]

extraCharacters
  = .* { return true }
// optional whitespace
_  = [ \t\r\n]*
// mandatory whitespace
__ = [ \t\r\n]+
