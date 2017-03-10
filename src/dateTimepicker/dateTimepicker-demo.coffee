document.querySelector('#datetimepicker').addEventListener("click", (event) ->
  a = dateTimepicker()
  a.$on 'valueChanged', (date) ->
    console.log date
, false)
