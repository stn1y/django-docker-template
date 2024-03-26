const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
let isProcessingComplete = false;
let secondFormSubmitted = false;
let fileName = '';
let encodedDownloadLink = '';
let firstFormInputIsValid = false;
let secondFormInputIsValid = true;
let isError = false;

function fitTitle() {
  var indexTitleContainer = document.getElementById('index-title-container');
  var indexTitle = document.getElementById('index-title');
  var fontSize = 100;

  indexTitle.style.fontSize = fontSize + 'px';
  while (indexTitle.offsetWidth > indexTitleContainer.offsetWidth) {
    fontSize--;
    indexTitle.style.fontSize = fontSize + 'px';
    indexTitleContainer.style.height = indexTitle.offsetHeight + 'px';
  }
  while (indexTitle.offsetWidth < indexTitleContainer.offsetWidth) {
    fontSize++;
    indexTitle.style.fontSize = fontSize + 'px';
    indexTitleContainer.style.height = indexTitle.offsetHeight + 'px';
  }
}

window.onload = function() {
  fitTitle();
}

window.addEventListener('resize', fitTitle);

document.addEventListener('DOMContentLoaded', function() {
  ig_vd_first_formSubmit();
  ig_vd_second_formSubmit();
  ig_vd_first_formValidity();
  ig_vd_second_formValidity();
  firstSubmitHover();
  secondSubmitHover();
})

window.onpopstate = function(event) {
  const stepNum = event.state.stepNum;
  console.log(stepNum);
}

function loadAnimation() {
  const secondForm = document.getElementById('second-form');
  const loaderContainer = document.getElementById('loader-container');
  secondForm.style.display = 'none';
  loaderContainer.style.display = 'flex';
}

function loadError(errorType) {
  // resets and alerts user
  console.log(errorType);
  const alert = document.getElementById('first-ig-vd-input-alert');
  const firstForm = document.getElementById('first-form');
  const secondForm = document.getElementById('second-form');
  const si3 = document.getElementById('si-3');
  const si5 = document.getElementById('si-5');
  si3.style.backgroundColor = '';
  si5.style.backgroundColor = '';

  alert.textContent = 'ERROR: CHECK LINK';
  firstForm.style.display = 'flex';
  secondForm.style.display = 'none';

  // reset
  isProcessingComplete = false;
  secondFormSubmitted = false;
  fileName = '';
  encodedDownloadLink = '';
  firstFormInputIsValid = false;
  secondFormInputIsValid = true;
  isError = false;
}

// async function decodeDownloadLink(edl) {
//   try {
//     const response = await fetch('decode', {
//       method: 'POST',
//       headers: {
//         'Content-Type': 'application/json',
//         'X-CSRFToken': csrfToken
//       },
//       body: JSON.stringify(
//         {'encodedDownloadLink': edl}
//       )
//     });
//     if (!response.ok) {
//       const errorResponse = await response.json();
//       console.log(errorResponse.message);
//       isError = true;
//       throw new Error(errorResponse.message);
//     }
//     const data = await response.json();
//     return data.decoded_download_link;
//   } catch (error) {
//     console.error('Error:', error);
//   }
// }

function ig_vd_first_formActivate() {
  const firstForm = document.getElementById('first-form');
  const secondForm = document.getElementById('second-form');
  const downloadForm = document.getElementById('download-form');
  firstForm.style.display = 'flex';
  secondForm.style.display = 'none';
  downloadForm.style.display = 'none';
}

function ig_vd_second_formActivate() {
  const firstForm = document.getElementById('first-form');
  const secondForm = document.getElementById('second-form');
  const downloadForm = document.getElementById('download-form');
  firstForm.style.display = 'none';
  secondForm.style.display = 'flex';
  downloadForm.style.display = 'none';
}

function ig_vd_first_formValidity() {

  const inputField = document.getElementById('first-ig-vd-input');
  const label = document.getElementById('first-ig-vd-input-label');
  inputField.addEventListener('input', function() {
    const inputValue = inputField.value;
    firstFormInputIsValid = inputValue.startsWith('https://www.instagram.com/');
    
    if (inputValue == '' || firstFormInputIsValid) {
      label.style.color = '';
    } else {
      label.style.color = 'rgb(227, 38, 20)';
    }

  })
}

function ig_vd_second_formValidity() {
  const inputField = document.getElementById('second-ig-vd-input');
  const label = document.getElementById('second-ig-vd-input-label');
  const forbiddenChars = ['<', '>', ':', '"', '/', '\\', '|', '?', '*'];
  const alert = document.getElementById('second-ig-vd-input-alert');
  inputField.addEventListener('input', function() {
    const inputValue = inputField.value;
    secondFormInputIsValid = true;
    for (let i = 0; i < inputValue.length; i++) {
      if (forbiddenChars.includes(inputValue[i])) {
        secondFormInputIsValid = false;
        break;
      }
    }
    if (secondFormInputIsValid) {
      label.style.color = '';
      alert.style.color = '';
    } else {
      label.style.color = 'rgb(227, 38, 20)';
      alert.style.color = 'rgb(227, 38, 20)';
    }
  })
}

async function ig_vd_first_formSubmit() {
  const button = document.getElementById('first-ig-vd-submit');
  const inputContainer = document.getElementById('first-ig-vd-input-and-alert-container');
  const input = document.getElementById('first-ig-vd-input');
  const label = document.getElementById('first-ig-vd-input-label');
  // const si1 = document.getElementById('si-1');
  // const si3 = document.getElementById('si-3');
  button.addEventListener('click', async function() {
    if (!firstFormInputIsValid) {
      input.style.border = '2px solid rgb(227, 38, 20)';
      label.style.color = 'rgb(227, 38, 20)';
      inputContainer.classList.remove('invalid-shake-animation');
      void input.offsetWidth;
      inputContainer.classList.add('invalid-shake-animation');
      setTimeout(function() {
        label.style.color = 'black';
        input.style.border = '2px solid black';
      }, 500);
      
    } else {
      // si1.style.animation = 'none';
      // si3.style.backgroundColor = 'rgb(191, 64, 191)';
      // si3.style.animation = 'blink 1s infinite'
      stepIndicate(2);
      ig_vd_second_formActivate();
      const input = document.getElementById('first-ig-vd-input').value;
      try {
        const response = await fetch('process', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken
          },
          body: JSON.stringify(
            {'input_url': input}
          ),
        });

        if (!response.ok) {
          const errorResponse = await response.json();
          // console.log(errorResponse.message);
          isError = true;
          // console.log('response not ok');
          if (secondFormSubmitted) {
            loadError('process');
          }
          throw new Error(errorResponse.message);
        }

        const data = await response.json();
        encodedDownloadLink = data.encoded_download_link;
        if (secondFormSubmitted) {
          if (isError) {
            loadError('process');
          }
          stepIndicate(3);
          createDownloadLink();
        } else {
          isProcessingComplete = true;
        }
      } catch (error) {
        console.error('Error:', error);
      }
    }
  }); 
}

function ig_vd_second_formSubmit() {
  const button = document.getElementById('second-ig-vd-submit');
  const inputContainer = document.getElementById('second-ig-vd-input-and-alert-container');
  const input = document.getElementById('second-ig-vd-input');
  const label = document.getElementById('second-ig-vd-input-label');
  const alert = document.getElementById('second-ig-vd-input-alert');
  button.addEventListener('click', function() {
    if (!secondFormInputIsValid) {
      // alert.style.color =  'rgb(227, 38, 20)';
      alert.style.display = 'block';
      input.style.border = '2px solid rgb(227, 38, 20)';
      label.style.color = 'rgb(227, 38, 20)';
      inputContainer.classList.remove('invalid-shake-animation');
      void input.offsetWidth;
      inputContainer.classList.add('invalid-shake-animation');
      setTimeout(function() {
        // alert.style.color = '';
        label.style.color = '';
        input.style.border = '';
      }, 500);
    } else {

      if (isError) {
        loadError('process')
      }

      const input = document.getElementById('second-ig-vd-input').value;
      if (input != '') {
        fileName = input;
      }
      if (isProcessingComplete) {
        stepIndicate(3);
        createDownloadLink();
      } else {
        secondFormSubmitted = true;
        stepIndicate(2.5);
        loadAnimation();
      }
    }
  })
}

async function createDownloadLink() {
  try {
    const response = await fetch('create_download_link', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken
      },
      body: JSON.stringify({
        'encodedDownloadLink': encodedDownloadLink, 
        'fileName': fileName
      }),
    });
    if (!response.ok) {
      const errorResponse = await response.json();
      console.log(errorResponse.message);
      isError = true;
      loadError('createDownloadLink');
      throw new Error(errorResponse.message);
    }
    const data = await response.json();
    const downloadLink = data.download_link;
    showDownloadLink(downloadLink);
  } catch (error) {
    console.error('Error:', error);
  }
}

async function showDownloadLink(downloadLink) {
  const secondForm = document.getElementById('second-form');
  const downloadForm = document.getElementById('download-form');
  const linkDisplay = document.getElementById('download-ig-vd-input');
  const loaderContainer = document.getElementById('loader-container');
  linkDisplay.value = downloadLink;
  secondForm.style.display = 'none';
  loaderContainer.style.display = 'none';
  downloadForm.style.display = 'flex';
}

function firstSubmitHover() {
  const submit = document.getElementById('first-ig-vd-submit');
  submit.addEventListener('mouseenter', function() {
    if (firstFormInputIsValid) {
      submit.style.backgroundColor = 'rgb(18, 219, 38)';
    } else {
      submit.style.backgroundColor = 'rgb(227, 38, 20)';
    }
  })
  submit.addEventListener('mouseleave', function() {
    submit.style.backgroundColor = '';
  })
}

function secondSubmitHover() {
  const submit = document.getElementById('second-ig-vd-submit');
  submit.addEventListener('mouseenter', function() {
    if (secondFormInputIsValid) {
      submit.style.backgroundColor = 'rgb(18, 219, 38)';
    } else {
      submit.style.backgroundColor = 'rgb(227, 38, 20)';
    }
  })
  submit.addEventListener('mouseleave', function() {
    submit.style.backgroundColor = '';
  })
}

function stepIndicate(step) {
  const si1 = document.getElementById('si-1');
  const si3 = document.getElementById('si-3');
  const si5 = document.getElementById('si-5');

  if (step == 2) {
    si1.style.animation = 'none';
    si3.style.backgroundColor = 'rgb(191, 64, 191)';
    si3.style.animation = 'blink 1s infinite'
  } else if (step == 2.5) {
    si3.style.animation = 'none';
    si3.style.backgrounColor = 'rgb(191, 64, 191)';
    si5.style.backgroundColor = 'rgb(191, 64, 191)'
    si5.style.animation = 'blink 1s infinite'
  } else {
    si5.style.animation = 'none';
  }

}