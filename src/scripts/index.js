var parser = require('./peg.pegjs');

const input = document.getElementById('input');
const output = document.getElementById('output');
const extraOutput = document.getElementById('extraOutput');

input.addEventListener('input', (e) => {
  window.localStorage.setItem('pegjs', e.target.value);
  const { type, message, payload } = parseValue(e.target.value);
  if (type === 'result') {
    output.classList.remove('error');
    output.innerText = JSON.stringify(message, null, '\t');
  } else {
    output.classList.add('error');
    output.innerText = JSON.stringify(message);
    throw new Error(payload);
  }
});

function parseValue(input) {
  try {
    const result = parser.parse(input);
    return {
      input,
      type: 'result',
      message: result,
    };
  } catch (err) {
    return {
      input,
      type: 'error',
      message: err.message,
      payload: err,
    };
  }
}
input.value = window.localStorage.getItem('pegjs');
// input.value = 'l darken show 1 dd / l show REMOVE';
// input.value = 'l darken show 1 dd';
// input.value = "#ff0";
input.dispatchEvent(new Event('input'));

const tests = [
  's i 1px #ff0',
  's #ff0 i',
  's 1',
  's c 1px #ff0',
  'f -',
  'f #ff0000, f - rgb(255,0,255)',
  '#ff0000, rgb(255,0,255), #ff0000',
  '#f0f',
  '#ff0000',
  'l 20%, o 20%',
  'l 0.2, o 0.2',
  'l 20, o 20',
  'l show, l hide',
  'l overlay',
  'cr 8 4 4 8',
  'xwyh+20, w20',
  'hsl(300,0%,0%)',
  'hsla(100,10%,10%, 0.2)',
  'rgb(255,0,255)',
];

extraOutput.innerHTML = tests
  .map((test) => {
    const result = parseValue(test);

    return `
            <div class="${result.type}">
                <strong>${result.input}</strong><br>
                <pre>
                    ${JSON.stringify(result.message, null, ' ')}
                </pre>
            </div>`;
  })
  .join('');
