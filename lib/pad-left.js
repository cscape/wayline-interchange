/* eslint-disable */
var cache
var res = ''

function repeat (e, r) {
  if (typeof e !== 'string') throw new TypeError('expected a string')
  if (r === 1) return e
  if (r === 2) return e + e
  var t = e.length * r
  if (cache !== e || cache == null) cache = e, res = ''
  else if (res.length >= t) return res.substr(0, t)
  for (; t > res.length && r > 1;) 1 & r && (res += e), r >>= 1, e += e
  return (res = (res += e).substr(0, t))
}

/**
 * Add left padding to a string
 * @param {string} s String to pad
 * @param {number} n Length of string to pad to
 * @param {string} c Character to pad with
 */
const padLeft = (s, n, c) => {
  return (s = String(s), n === null ? s : repeat(c = c === 0 ? '0' : c ? String(c) : ' ', n - s.length) + s)
}

module.exports = padLeft
