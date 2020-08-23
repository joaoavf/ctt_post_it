import 'dart:math';
import 'package:post_it/functions/galois_field.dart';

List<int> rsCorrectMessage(List<int> message_in, {int nsym = 12}) {
  initTables();
  List<int> message_out = new List.from(message_in);
  List<int> erase_pos = [];
  for (int i = 0; i < message_out.length; i++) {
    if (message_out[i] < 0) {
      message_out[i] = 0;
      erase_pos.add(i);
    }
  }
  if (erase_pos.length > nsym) return null;
  List<int> synd = _rsCalculateSyndrome(message_out, nsym);
  if (_max(synd) == 0) return message_out;
  List<int> fsynd = _rsForneySyndrome(synd, erase_pos, message_out.length);
  List<int> err_polynomial = _rsGeneratorErrorPolynomial(fsynd);
  List<int> err_pos =
      _rsFindErrors(err_polynomial.reversed.toList(), message_out.length);
  if (err_pos == null) return null;
  message_out = _rsCorrectErrata(message_out, synd, erase_pos..addAll(err_pos));
  synd = _rsCalculateSyndrome(message_out, nsym);
  if (_max(synd) > 0) return null;
  return message_out;
}

///Reed-Solomon main encoding function, using polynomial division (algorithm Extended Synthetic Division)

List<int> rsEncodeMessage(List<int> message_in, int nsym) {
  List<int> gen = generatePolynomial(nsym);
  List<int> message_out =
      new List.filled(message_in.length + gen.length - 1, 0);
  message_out.setAll(0, message_in);
  for (int i = 0; i < message_in.length; i++) {
    int coef = message_out[i];
    if (coef != 0) {
      for (int j = 1; j < gen.length; j++) {
        message_out[i + j] ^= gfMultiply(gen[j], coef);
      }
    }
  }
  message_out.setAll(0, message_in);
  return []..addAll(message_out);
}

int _max(List<int> list) {
  int r = null;
  for (int i = 1; i < list.length; i++) {
    if (list[i - 1].compareTo(r == null ? list[i] : r) >= 0) {
      r = list[i];
    }
  }
  return r;
}

/**
 * Calculate the syndromes
 */
List<int> _rsCalculateSyndrome(List<int> msg, int nsym,
    {fcr = 1, generator = 2}) {
  List<int> synd = new List.filled(nsym, 0);
  for (int i = 0; i < nsym; i++) {
    synd[i] = gfPolynomialEval(msg, gfPow(generator, i + fcr));
  }
  return synd;
}

/**
 * Forney algorithm, computes the values (error magnitude) to correct the input message
 */
List<int> _rsCorrectErrata(List<int> message, List<int> synd, List<int> err_pos,
    {fcr = 1, generator = 2}) {
  List<int> coef_pos = <int>[];
  err_pos.forEach((int value) => coef_pos.add(message.length - 1 - value));
  List<int> err_loc = _rsFindErrataLocator(coef_pos);
  List<int> reversed = new List.from(synd.sublist(0).reversed);
  List<int> err_eval =
      _rsFindErrorEvaluator(reversed, err_loc, err_pos.length - 1);
  err_eval = err_eval.reversed.toList();

  List<int> X = []; // will store the position of the errors
  coef_pos.forEach((element) {
    int l = 63 - element;
    X.add(gfPow(generator, -l));
  });

  for (int i = 0; i < X.length; i++) {
    int Xi = X[i];
    int Xi_inv = gfInverse(Xi);
    List err_loc_prime_tmp = [];

    for (int j = 0; j < X.length; j++) {
      if (j != i) {
        err_loc_prime_tmp.add(1 ^ gfMultiply(Xi_inv, X[j]));
      }
    }

    int err_loc_prime = 1;

    for (int z = 0; z < err_loc_prime_tmp.length; z++) {
      int coef = err_loc_prime_tmp[z];
      err_loc_prime = gfMultiply(err_loc_prime, coef);
    }
    if (err_loc_prime == 0) {
      return null;
    }

    int y = gfPolynomialEval(err_eval, Xi_inv);
    y = gfMultiply(gfPow(Xi, 1 - fcr), y);

    int magnitude = gfDivide(y, err_loc_prime);
    message[i] ^= magnitude;
  }
  return message;
}

/**
 * Compute the erasures/errors/errata locator polynomial from the erasures/errors/errata positions
 * (the positions must be relative to the x coefficient, eg: "hello worldxxxxxxxxx" is tampered to "h_ll_ worldxxxxxxxxx"
 * with xxxxxxxxx being the ecc of length n-k=9, here the string positions are [1, 4], but the coefficients are reversed
 * since the ecc characters are placed as the first coefficients of the polynomial, thus the coefficients of the
 * erased characters are n-1 - [1, 4] = [18, 15] = erasures_loc to be specified as an argument.
 */
List<int> _rsFindErrataLocator(List<int> e_pos, {int x: null, generator = 2}) {
  List<int> e_loc = [1];
  for (x in e_pos) {
    e_loc = gfPolynomialMultiply(
        e_loc, gfPolynomialAdd([1], [gfPow(generator, x), 0]));
  }
  return e_loc;
}

/**
 * Compute the error (or erasures if you supply sigma=erasures locator polynomial, or errata) evaluator polynomial Omega
 * from the syndrome and the error/erasures/errata locator Sigma.
 */
List<int> _rsFindErrorEvaluator(List<int> synd, List<int> err_loc, int nsym) {
  List<int> remainder = gfPolynomialDivide(gfPolynomialMultiply(synd, err_loc),
      [1]..addAll(new List.filled(nsym + 1, 0)));
  return remainder;
}

/**
 * Find the roots (ie, where evaluation = zero) of error polynomial by brute-force trial, this is a sort of Chien's search
 * (but less efficient, Chien's search is a way to evaluate the polynomial such that each evaluation only takes constant time)
 */
List<int> _rsFindErrors(List<int> err_loc, int nmess, {generator = 2}) {
  int errs = err_loc.length - 1;
  List<int> err_pos = <int>[];
  for (int i = 0; i < nmess; i++) {
    if (gfPolynomialEval(err_loc, gfPow(generator, i)) == 0) {
      err_pos.add(nmess - 1 - i);
    }
  }
  if (err_pos.length != errs) {
    return null;
  }
  return err_pos;
}

/**
 * Calculating the Forney syndromes
 */
List<int> _rsForneySyndrome(List<int> synd, List<int> pos, int nmess,
    {generator = 2}) {
  List<int> fsynd = new List.from(synd);
  pos.forEach((int value) {
    int x = pow(generator, nmess - 1 - value);
    for (int j = 0; j < fsynd.length - 1; j++) {
      fsynd[j] = gfMultiply(fsynd[j], x) ^ fsynd[j + 1];
    }
    fsynd.removeLast();
  });
  return fsynd;
}

/**
 * Find error locator polynomial with Berlekamp-Massey algorithm
 */
List<int> _rsGeneratorErrorPolynomial(List<int> synd) {
  List<int> err_loc = [1];
  List<int> old_loc = [1];

  for (int i = 0; i < synd.length; i++) {
    old_loc.add(0);
    int delta = synd[i];
    for (int j = 1; j < err_loc.length; j++) {
      delta ^= gfMultiply(err_loc[err_loc.length - 1 - j], synd[i - j]);
    }
    if (delta != 0) {
      if (old_loc.length > err_loc.length) {
        List<int> new_loc = gfPolynomialScale(old_loc, delta);
        old_loc = gfPolynomialScale(err_loc, gfInverse(delta));
        err_loc = new_loc;
      }
      err_loc = gfPolynomialAdd(err_loc, gfPolynomialScale(old_loc, delta));
    }
  }
  err_loc.removeWhere((int value) => value == 0);
  int errs = err_loc.length - 1;
  if (errs * 2 > synd.length) {
    return null;
  }
  return err_loc;
}

/**
 * Computes the generator polynomial for a given number of error correction symbols
 */
List<int> generatePolynomial(int nsym, {fcr = 1, generator = 2}) {
  List<int> g = [1];
  for (int i = 0; i < nsym; i++) {
    g = gfPolynomialMultiply(g, [1, gfPow(generator, i + fcr)]);
  }
  return g;
}

gfPow(x, power) {
  final int field_charac = 63;
  return GF_EXP[(GF_LOG[x] * power) % field_charac];
}
