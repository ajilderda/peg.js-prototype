{
    var tinycolor = require('tinycolor2');
    const isNotNullOrUndefined = (input) => input !== null && input !== undefined;
    const toColor = ({type = 'FILL', color, operator, defaultOperator = '='}) => {
      return {
        type,
        operator,
        defaultOperator,
        color,
      }
    };

    function toRgb(value) {
      const color = tinycolor(value);
      return color.toRgb();
    }

    const rgbVal = (value) => {
      return value.includes('%') ? value * 255 : value;
    };

    const toUnit = (value, type) => ({ value, type });

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
          defaultOperator,
          value,
        }
      })
    }

    // top / right / bottom / right operation, f.e. for defining corner radius
    // values (2 4 2 2)
    const toCornerRadius = (type, valueStr) => {
      const values = valueStr.split(' ').filter(item => item !== '');
      const [topRightRadius, bottomRightRadius, bottomLeftRadius, topLeftRadius] = values;

      if (values.length === 1)
        return { cornerRadius: values[0] }
      else if (values.length === 2)
        return {
          topRightRadius,
          bottomRightRadius,
          bottomLeftRadius: values[0],
          topLeftRadius: values[1],
        }
      else if (values.length === 3)
        return {
          topRightRadius,
          bottomRightRadius,
          bottomLeftRadius,
          topLeftRadius: values[1],
        }

      return {
        topRightRadius,
        bottomRightRadius,
        bottomLeftRadius,
        topLeftRadius,
      }
    }

    const toBlendMode = mode => {
      const blendMode = mode.toUpperCase();
      return {
        type: 'BLEND_MODE',
        blendMode,
      }
    }

    const toVisible = visible => {
      return {
        type: 'VISIBILITY',
        visible
      }
    }

    const toOpacity = (value, operator = null, defaultOperator = '=') => {
      const numValue = parseFloat(value.replace('%', ''), 10);
      const opacity = Number.isInteger(numValue) && value !== '1' ? numValue / 100 : numValue;
      return {
        operator,
        defaultOperator,
        opacity,
      };
    }

    // any order is allowed, but only once
    // tweaked from https://gist.github.com/nedzadarek/b0bf9aaaefd084be4f411a6767eee7fa
    // SO topic: https://stackoverflow.com/a/37137486
    function disallowDuplicates(elements){
    	if (elements < 1) return false;

      // count the amount of items
      const keyCount = elements.reduce((acc, el) => {
        const { key } = el;
        const count = acc[el.key] || 0;
        return {...acc, [key]: count + 1}
      }, {})
      // check if any of the items are > 1. If so, return false
      const isValid = !Object.values(keyCount).some(el => el > 1);

      return isValid;
    }
}

start = result:splitActions {
  if (!Array.isArray(result)) return [result]
  return result;
}
// Split actions
splitActions = _ first:(actionsWithExtraChars Separator) _ second:splitActions {
  if (second.length) return [...first, ...second]
  else return [...first, second];
}
/ actionsWithExtraChars
/ first:(ALL Separator) second:splitActions {
  if (second.length) return [...first, ...second]
  else return [...first, second];
}
/ Separator ALL Separator
/ ALL Separator
/ ALL
// match all characters except the separator (,)
ALL = chars:[^,]* { return {extra: chars.join('') }}

actionsWithExtraChars = (actions:action extraChars:ALL {
  if (Array.isArray(actions)) return { actions, extraChars };
  return {...actions, ...extraChars}
})
Separator
  = "," {
    return {
      type: 'separator',
      text: ','
    }
  }

Character
  = .


// ACTIONS
action = fill / xywh / cornerRadius / layerActions / stroke

fill = 'f'i _ operator:plusOrMinus? _ color:color { return toColor({type: 'FILL', color, operator}) }
  / 'f'i color:color { return toColor({type: 'FILL', color}) }
  // remove fill without specifying color, f.e. f -
  / 'f'i _ operator:'-' { return toColor({type: 'FILL', operator}) }
  / color:color { return toColor({type: 'FILL', color}) }

// all fields optional where any order is allowed, but only once
stroke = 's'i __ matches:(elements:(
    strokeWeight:unit _ { return { key: 'strokeWeight', value: { strokeWeight } } }
    / color:color _ { return { key: 'color', value: { color: color } } }
    / operator:operator _ { return { key: 'operator', value: { operator: operator } } }
    / strokeAlign:[ico] _ {
      const map = {i: 'INSIDE', c: 'CENTER', o: 'OUTSIDE'};
      return { key: 'align', value: { strokeAlign: map[strokeAlign] } }
    }
  )+
  &{ return disallowDuplicates(elements) } // validate input (keys are only permitted once)
  { return elements.map(el => el.value) }  // use the value (strip the key from the output)
) { return {
  type: 'STROKE',
  ...matches.reduce((acc, match) => ({...acc, ...match}), {})
} }
  / 's'i _ operator:'-' { return {type: 'STROKE', operator} }

xywh = xywh:XYWH _ operator:operator _ value:unit { return toOperation(xywh, value, operator) }
  / xywh:XYWH _ value:unit  { return toOperation(xywh, value, null, '=') }

// layerActions = 'l' _ mode:BLEND_MODE { return toBlendMode(mode) }
//   / 'l' _ value:('show'i { return true } / 'hide'i { return false }) { return toVisible(value) }
//   / [lo] _ value:numOrPercent { return toOpacity(value) }
//   / [lo] _ operator:operator _ value:numOrPercent { return toOpacity(value, operator) }

layerActions = 'l'i __ matches:(elements:(
    value:BLEND_MODE _ { return { key: 'blendMode', value: { blendMode: value} } }
    / value:('show'i { return true } / 'hide'i { return false }) _ { return { key: 'visibility', value: { visibility: value } } }
    / value:numOrPercent { return { key: 'opacity', value: {opacity: toOpacity(value)}} }
  )+
  &{ return disallowDuplicates(elements) } // validate input (keys are only permitted once)
  { return elements.map(el => el.value) }  // use the value (strip the key from the output)
) { return {
  type: 'LAYER',
  ...matches.reduce((acc, match) => ({...acc, ...match}), {})
} }

cornerRadius = type:'cr' values:$(__ unit)+ { return toCornerRadius(type, values) }

// UNITS
unit = $(number:number type:'px')
  / number:number
pctUnit = number:number type:'%' { return toUnit(number, type) }
pxOrPctUnit = pctUnit / unit

BLEND_MODE = 'color'i / 'color burn'i / 'color dodge'i / 'darken'i / 'difference'i / 'exclusion'i / 'hue'i / 'hard light'i / 'lighten'i / 'linear burn'i / 'linear dodge'i / 'luminosity'i / 'multiply'i / 'normal'i / 'overlay'i / 'saturation'i / 'screen'i / 'soft light'i
XYWH = [xwyh]i+;

color = colorRGB / colorHSL / colorHex
colorHex = c:$('#' colorHex3 colorHex3?) { return toRgb(c); }
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
separator = _ '/' _ { return { type: 'separator' } }
combinedAction = [lrtbwhaxy]*
operator = [\/+\-*%=]
integer = digits:[0-9]+ { return digits.join('') }
digit = [0-9]

extraChars
  = chars:.* { return chars.join('')}
// optional whitespace
_  = [ \t\r\n]*
// mandatory whitespace
__ = [ \t\r\n]+
