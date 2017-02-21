document.querySelector('.btn-success').addEventListener('click', () ->
  Alertify({ content:'登陆成功',type:'success' })
,false)
document.querySelector('.btn-warning').addEventListener('click', () ->
  Alertify({ content:'警告',type:'warning' })
,false)
document.querySelector('.btn-danger').addEventListener('click', () ->
  Alertify({ content:'验证码错误',type:'danger' })
,false)
document.querySelector('.btn-info').addEventListener('click', () ->
  Alertify({ content:'一般信息',type:'info' })
,false)
