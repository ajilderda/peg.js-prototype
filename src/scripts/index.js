var parser = require('./peg.pegjs');

const input = document.getElementById('input');
const output = document.getElementById('output');
const extraOutput = document.getElementById('extraOutput');

input.addEventListener('input', (e) => {
  const { type, message, payload } = parseValue(e.target.value);
  if (type === 'result') {
    output.classList.remove('error');
    output.innerText = JSON.stringify(JSON.parse(message), null, '\t');
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
      message: JSON.stringify(result),
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
input.value = 'f rgb(255,0,255)';
// input.value = "#ff0";
input.dispatchEvent(new Event('input'));

const tests = [
  '#f0f',
  '#ff0000',
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
                ${result.message}
            </div>`;
  })
  .join('');
