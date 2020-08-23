library galois_field;

import "dart:typed_data";
import "dart:math";

List<int> GF_EXP;
List<int> GF_LOG;
int GF_EXP_SIZE;
int GF_LOG_SIZE;

int gfDivide(int x, int y) {
  if (y == 0) {
    throw "Divide by 0";
  }
  if (x == 0) {
    return 0;
  }
  return GF_EXP[GF_LOG[x] + (GF_LOG_SIZE - 1) - GF_LOG[y]];
}

int gfInverse(int y) {
  return gfDivide(1, y);
}

int gfMultiply(int x, int y) {
  if (x == 0 || y == 0) return 0;
  return GF_EXP[GF_LOG[x] + GF_LOG[y]];
}

/**
 * Addition two polynomials (using exclusive-or, as usual)
 */
List<int> gfPolynomialAdd(List<int> p, List<int> q) {
  List<int> r = new List.filled(p.length > q.length ? p.length : q.length, 0);
  for (int i = 0; i < p.length; i++) {
    r[i + r.length - p.length] = p[i];
  }
  for (int i = 0; i < q.length; i++) {
    r[i + r.length - q.length] ^= q[i];
  }
  return <int>[]..addAll(r);
}

/**
 * Fast polynomial division by using Extended Synthetic Division and optimized for GF(2^p) computations
 * (doesn't work with standard polynomials outside of this galois field, see the Wikipedia article for generic algorithm).
 */
List<int> gfPolynomialDivide(List<int> dividend, List<int> divisor) {
  Uint8List msg_out = new Uint8List.fromList(dividend);
  for (int i = 0; i < dividend.length - divisor.length - 1; i++) {
    int coef = msg_out[i];
    if (coef != 0) {
      for (int j = 1; j < divisor.length; j++) {
        msg_out[i + j] += -divisor[j] * coef;
      }
    }
  }
  int separator = divisor.length ;
  return msg_out.sublist(msg_out.length - separator);
}

/**
 * Evaluate a polynomial at a particular value of x, producing a scalar result
 */
int gfPolynomialEval(List<int> p, int x) {
  int y = p[0];
  for (int i = 1; i < p.length; i++) {
    y = gfMultiply(y, x) ^ p[i];
  }
  return y;
}

/**
 * Multiplies two polynomials
 */
List<int> gfPolynomialMultiply(List<int> p, List<int> q) {
  List<int> r = new List.filled(p.length + q.length - 1, 0);
  for (int j = 0; j < q.length; j++) {
    for (int i = 0; i < p.length; i++) {
      r[i + j] ^= gfMultiply(p[i], q[j]);
    }
  }
  return <int>[]..addAll(r);
}

/**
 * Multiplies a polynomial by a scalar
 */
List<int> gfPolynomialScale(List<int> p, int x) {
  List<int> r = new List.filled(p.length, 0);
  for (int i = 0; i < p.length; i++) {
    r[i] = gfMultiply(p[i], x);
  }
  return <int>[]..addAll(r);
}

/*
 * TODO(kleak): see how we can let the user choose
 * Possible value here (0x0, 0x3, 0x7, 0xB, 0x13, 0x25, 0x43, 0x83, 0x11D, 0x211, 0x409, 0x805, 0x1053, 0x201B, 0x402B, 0x8003, 0x1100B)
 */
void initTables() => _initTables();

/**
 * Precompute the logarithm and anti-log tables for faster computation later, using the provided primitive polynomial
 */

void _initTables({int prim = 67, int generator = 2, int c_exp = 6}) {
  int field_charac = pow(2, c_exp).toInt() - 1;
  GF_LOG_SIZE = 64;

  GF_EXP = new List.filled(field_charac * 2, 1);
  GF_LOG = new List.filled(field_charac + 1, 0);

  int x = 1;
  for (int i = 0; i < field_charac; i++) {
    GF_EXP[i] = x;
    GF_LOG[x] = i;

    x <<= 1;
    if (x & GF_LOG_SIZE == GF_LOG_SIZE) {
      x ^= prim;
    }
  }
  for (int i = field_charac; i < field_charac * 2; i++) {
    GF_EXP[i] = GF_EXP[i - field_charac];
  }
}
