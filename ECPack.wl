(* ::Package:: *)

(* ECPack -- elliptic curve toolkit: every public command starts with ECP *)

BeginPackage["ECPack`"];

$ECPVersion::usage="$ECPVersion is the version string of the loaded ECPack package.";
$ECPCurrentEC::usage="$ECPCurrentEC is the global session curve Association set by ECPSetEC. It has keys \"Coefficients\" -> {a1,a2,a3,a4,a6} and \"Equation\". Functions that accept a curve argument of Automatic read it from here.";
ECPSetEC::usage="ECPSetEC[{a1, a2, a3, a4, a6}] or ECPSetEC[a1, a2, a3, a4, a6] sets the global session variable $ECPCurrentEC to an Association holding the long Weierstrass coefficients {a1,a2,a3,a4,a6} and the corresponding equation, and returns it.";
ECPPointQ::usage = "ECPPointQ[{x1, y1}, F] (or ECPPointQ[F, x1, y1]) checks if the point {x1, y1} lies on the curve F. F may be a curve Association (as returned by ECPSetEC), an equation, or a raw polynomial, in the variables x/y or X/Y.";

ECPShortWierstrass::usage="ECPShortWierstrass[curve] converts a given curve to short Weierstrass form, returning the polynomial y^2-(x^3+A x+B) in the curve's own variables. Accepts a polynomial, an equation, a coefficient list or a curve Association. (Legacy alias of ECPShortWeierstrassForm.)";
ECPShortWeierstrassForm::usage="ECPShortWeierstrassForm[curve] returns the short Weierstrass polynomial y^2-(x^3+A x+B); it is the preferred spelling (ECPShortWierstrass is kept as a legacy alias).";
ECPToShortWeierstrass::usage="ECPToShortWeierstrass[E] converts a long Weierstrass form to a short Weierstrass form. Requires characteristic 0 or > 3; for a curve over F_p with p = 2 or 3 use ECPToShortWeierstrassFp (which returns the best form that exists there) or ECPNormalFormCharTwoThree.";
ECPLegendreToWeierstrass::usage="ECPLegendreToWeierstrass[lambda] converts the Legendre-form curve y^2 = x(x-1)(x-lambda) (lambda != 0,1) to short Weierstrass form, returning {A,B} such that y^2=x^3+Ax+B is isomorphic to it (verified by point-count matching across multiple primes). Uses the integral scaling A=-27c4, B=-54c6 of ECPShortWeierstrassForm (NOT the A=-c4/48, B=-c6/864 of ECPToShortWeierstrass; the two models are isomorphic via u = 6). Requires characteristic 0 or > 3.";
ECPQuarticToWeierstrass::usage="ECPQuarticToWeierstrass[{a,b,c,d,e}] converts the quartic curve y^2 = a x^4+b x^3+c x^2+d x+e to short Weierstrass form via the classical invariants I=12ae-3bd+c^2, J=72ace+9bcd-27ad^2-27eb^2-2c^3, returning {A,B}={-27I,-27J} (verified by point-count matching across multiple primes and multiple example quartics). This is always the Jacobian of the quartic curve; it is honestly isomorphic (not just isogenous/a twist) to the quartic model specifically when the quartic has a rational point (e.g. when a or e is a perfect square in the field).";
ECPNormalFormCharTwoThree::usage="ECPNormalFormCharTwoThree[{a1,a2,a3,a4,a6}, p] reduces a general (long) Weierstrass model to the standard normal form in characteristic p (p must be 2 or 3), where the usual char-0 simplification (completing the square/cube, as used by ECPToShortWeierstrass) is not available since it requires dividing by 2 or 3. For p=2: reduces to y^2+xy=x^3+a2 x^2+a6 (the 'ordinary' case, when a1 != 0) or y^2+a3 y=x^3+a4 x+a6 (the 'supersingular' case, when a1 = 0). For p=3: reduces to y^2=x^3+a2 x^2+a6 (ordinary, when b2 != 0) or y^2=x^3+a4 x+a6 (supersingular, when b2 = 0). Both cases in both characteristics were verified exhaustively (every nonsingular curve over F_2 and F_3) by point-count matching against the original curve. Returns an Association with the reduced coefficients, the (u,r,s,t) transformation used, and which case applied.\nAlso accepts short {A,B}, an Association, an equation or Automatic.\nECPNormalFormCharTwoThree[curve, {p, r}] works over F_(p^r), p = 2 or 3 (see ECPFiniteFieldInfo for the element notation). For p = 2 the ordinary case becomes y^2 + x y = x^3 + a2 x^2 + a6 with a2 in {0, gamma} (gamma = a fixed element of absolute trace 1, returned under \"Gamma\"; for r = 1 gamma = 1), and the result carries \"FieldOrder\".";
ECPToShortWeierstrassFp::usage="ECPToShortWeierstrassFp[curve, p] reduces a long Weierstrass model over the prime field F_p to the simplest form that exists over F_p, and returns an Association with keys \"Characteristic\", \"OriginalCoefficients\", \"ShortCoefficients\" (the {a1,a2,a3,a4,a6} of the reduced model), \"Transformation\" ({u,r,s,t}, meaning x = u^2 x' + r, y = u^3 y' + u^2 s x' + t), \"Case\", \"PureShortQ\", \"ShortPair\", \"Equation\", \"Discriminant\" and \"jInvariant\". curve may be long {a1,a2,a3,a4,a6}, short {A,B}, a curve Association, an equation/polynomial, or Automatic; integer coefficients (or rationals whose denominator is prime to p) are reduced mod p. What exists depends on the characteristic: for p > 3 the result is always a genuine short model y^2 = x^3 + A x + B (A = -c4/48, B = -c6/864 mod p). For p = 3 a genuine short model exists only when b2 = 0 (j = 0); otherwise the best possible form is y^2 = x^3 + a2 x^2 + a6. For p = 2 a genuine short model NEVER exists (y^2 = x^3 + A x + B is singular in characteristic 2); the result is y^2 + x y = x^3 + a2 x^2 + a6 (j != 0) or y^2 + a3 y = x^3 + a4 x + a6 (j = 0). \"PureShortQ\" is True exactly when the reduced model is y^2 = x^3 + A x + B, and then \"ShortPair\" is {A,B}; otherwise \"ShortPair\" is Missing[\"NotAvailable\"]. Over F_(p^r) pass {p, r} in place of p (elements are 0 and powers of g, see ECPFiniteFieldInfo); the result then also has the key \"FieldOrder\", the transformation and coefficients are written in the same 0 / g^k notation, and for p = 2 the ordinary case has a2 in {0, gamma} with gamma of absolute trace 1 (a2 can only be reduced modulo s^2 + s).";
ECPToShortCoordinatesFp::usage="ECPToShortCoordinatesFp[{x, y}, curve, p] maps a point of the long model 'curve' over F_p to the corresponding point of the reduced model returned by ECPToShortWeierstrassFp[curve, p]. Infinity maps to Infinity. The map is a group isomorphism. Coordinates are reduced mod p; the point must lie on the curve modulo p.";
ECPFromShortCoordinatesFp::usage="ECPFromShortCoordinatesFp[{X, Y}, curve, p] is the inverse of ECPToShortCoordinatesFp: it maps a point of the reduced model back to the original long model 'curve' over F_p. Note that 'curve' is the ORIGINAL long curve (the same one you passed to ECPToShortCoordinatesFp), not the reduced one.";

ECPCubicToWeierstrass::usage="ECPCubicToWeierstrass[P, curve, opts] converts a cubic equation to Weierstrass form, given a rational point P={x0,y0,z0} on it, and returns the long Weierstrass polynomial y^2+a1 x y+a3 y-(x^3+a2 x^2+a4 x+a6) (an equation Y^2==X^3+A X+B with \"Form\"->\"Short\"); \"Equivalence\"->True also prints the transformation. Requires characteristic 0 or > 3 -- it relies on Solve/Simplify-based symbolic reasoning throughout that has no built-in awareness of a finite-field modulus; use ECPCubicToWeierstrassCharTwoThree for characteristic 2 or 3. If the supplied curve is affine (2 variables) it is homogenised with respect to z automatically.";
ECPCubicToWeierstrassCharTwoThree::usage="ECPCubicToWeierstrassCharTwoThree[P, F, p] (or ECPCubicToWeierstrassCharTwoThree[F, P, p]) converts a general homogeneous cubic curve F=0 in 3 variables (detected by name: x, y, z (or X, Y, Z) take the roles of the three coordinates of P; other names are taken in alphabetical order) over a field of characteristic p (p must be 2 or 3) to general Weierstrass form, given a known INFLECTION POINT P={x0,y0,z0} on the curve. This is a real restriction relative to ECPCubicToWeierstrass: it does not search for a flex starting from an arbitrary point, since that search (locating a rational inflection point on a general cubic) needs separate, characteristic-specific care that is not implemented here -- you must supply a flex point yourself. Once given one, the reduction itself is pure (modular) linear algebra: move P to [0:1:0] and its tangent line to {z=0}, then normalize. Verified via point-count matching against concrete test cubics constructed by scrambling known Weierstrass curves with a random invertible linear change of coordinates, for both p=2 and p=3. Returns an Association with the general Weierstrass coefficients {a1,a2,a3,a4,a6}, the transformation matrix used, and the auxiliary points chosen.\nECPCubicToWeierstrassCharTwoThree[P, F, {p, r}] works over F_(p^r), p = 2 or 3: the coefficients of F and the coordinates of P are field elements in the notation of ECPFiniteFieldInfo (name the three coordinate variables x, y, z; a generator symbol such as g may occur in the coefficients). The returned matrix maps Weierstrass coordinates (X,Y,Z) to the original ones, and \"Scaling\" gives the factors applied to X and Y.";
ECPToShortCoordinates::usage="ECPToShortCoordinates[{x, y}, curve] converts a point on the long Weierstrass model 'curve' to coordinates on the short model produced by ECPToShortWeierstrass (A=-c4/48, B=-c6/864), via X = x+b2/12, Y = y+(a1 x+a3)/2.";
ECPToLongCoordinates::usage =
"ECPToLongCoordinates[pt, curve] converts point coordinates pt = {x, y} from a short Weierstrass model to long coordinates using the identity transformation {1, 0, 0, 0}.\n" <>
"ECPToLongCoordinates[pt, curve, {u, r, s, t}] takes a point pt = {x', y'} of the model ECPTransformWeierstrass[curve, {u,r,s,t}] and returns the point {x, y} of the long model curve, with x = u^2 x' + r and y = u^3 y' + u^2 s x' + t (inverse of ECPToMinimalPoint).\n" <>
"Note: ECPToShortCoordinates is NOT the inverse of the default form of ECPToLongCoordinates; to undo ECPToShortCoordinates use ECPFromShortCoordinates.";
ECPFromShortCoordinates::usage="ECPFromShortCoordinates[{X, Y}, curve] is the exact inverse of ECPToShortCoordinates: it maps a point on the short model back to the long model 'curve'.";
ECPToMinimalPoint::usage="ECPToMinimalPoint[{x, y}, {u, r, s, t}] maps a point on the original model to the model obtained by the Weierstrass isomorphism {u,r,s,t}. Use it with the \"Transformation\" returned by ECPMinimalModel.";
ECPFromMinimalPoint::usage="ECPFromMinimalPoint[{X, Y}, {u, r, s, t}] is the inverse of ECPToMinimalPoint.";

ECPPointOrder::usage="ECPPointOrder[point, curve] returns the exact order of a rational point, or Infinity if it has infinite order (by Mazur's theorem no rational torsion point has order > 12). Same as ECPFindPointOrder[point, curve, 12].";
ECPPointOrderFp::usage="ECPPointOrderFp[point, curve, p], ECPPointOrderFp[point, a, b, p] and ECPPointOrderFp[point, curve, {p, r}] are synonyms of ECPFindPointOrderFp.";
ECPFindPointOrder::usage="ECPFindPointOrder[point, curve, maxOrder] finds the order of a given point on the curve, or Infinity if it exceeds maxOrder (default 12, Mazur's bound). curve may be given in any form (short {A,B}, long {a1,a2,a3,a4,a6}, Association, equation, Automatic); ECPFindPointOrder[point, curve] uses the default maxOrder.";
ECPBachetDuplication::usage="ECPBachetDuplication[x, curve] returns Bachet's duplication formula: the x-coordinate of 2P as a rational function of the x-coordinate of P, x(2P) = (x^4 - b4 x^2 - 2 b6 x - b8)/(4 x^3 + b2 x^2 + 2 b4 x + b6), where b2,...,b8 are the usual invariants of the long model. For y^2 = x^3 + A x + B this is (x^4 - 2 A x^2 - 8 B x + A^2)/(4 (x^3 + A x + B)); for y^2 = x^3 + c it is (x^4 - 8 c x)/(4 (x^3 + c)). x may be a number or a symbol; the result is Infinity when 2P is the point at infinity.\nECPBachetDuplication[{x, y}, curve] returns the whole point 2P = {x(2P), y(2P)} for a point of the curve (checked), and ECPBachetDuplication[Infinity, curve] is Infinity. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";
ECPAdd::usage="ECPAdd[P1, P2, curve] performs point addition. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic; for anything other than short form, P1 and P2 are read and the result is returned in that same curve's own coordinates.";
ECPMultiply::usage="ECPMultiply[n, P, curve] performs scalar point multiplication. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic; for anything other than short form, P is read and the result is returned in that same curve's own coordinates.";

ECPMinimalQ::usage="ECPMinimalQ[{A, B}, p] checks whether the short Weierstrass model {A,B} is minimal at prime p. ECPMinimalQ[{A, B}] checks global minimality over the integers. ECPMinimalQ[curv, args] accepts a curve Association. NOTE: this tests minimality among SHORT models only (p^4 | A and p^6 | B); at p = 2 and 3 a short model can pass this test and still be non-minimal as a general Weierstrass model (e.g. y^2 = x^3 + 16 becomes y^2 + y = x^3 over Z). For the true minimality of a curve given in long form use ECPIsMinimal or ECPMinimalModel.\nECPMinimalQ[{a1,a2,a3,a4,a6}, p] and ECPMinimalQ[{a1,a2,a3,a4,a6}] test true Weierstrass minimality of a LONG model (Laska-Kraus); an equation, an Association carrying a long model, or Automatic is treated the same way.";
ECPWeierstrassDiscriminant::usage="ECPWeierstrassDiscriminant[{a1,a2,a3,a4,a6}] computes the full Weierstrass discriminant.";
ECPShortDiscriminant::usage="ECPShortDiscriminant[{A, B}] computes the discriminant -16(4A^3+27B^2) for the short form.";
ECPJInvariant::usage="ECPJInvariant[curve] computes the j-invariant of an elliptic curve.\n"<>"Accepts the short form {A, B} and the general form {a1, a2, a3, a4, a6}.\n"<>"Can also take a modulus p as a trailing parameter for finite field F_p calculations, or {p, r} for F_(p^r) (elements written 0 / g^k, see ECPFiniteFieldInfo).\nAn Association, an equation or Automatic is also accepted, with or without the trailing prime.";
ECPMinimalModel::usage="ECPMinimalModel[{a1,a2,a3,a4,a6}, opts] iteratively finds the minimal model for an elliptic curve and normalises it so that a1, a3 in {0,1} and a2 in {-1,0,1}.\nAlso accepts short {A,B} (treated as the long model {0,0,0,A,B}), an Association, an equation or Automatic; the result is always a long minimal model.";
ECPMinimalModelShort::usage="ECPMinimalModelShort[{A, B}] finds the minimal model for a short Weierstrass form.\nAlso accepts a long model, an Association, an equation or Automatic; a long model is handled by ECPMinimalModel (the result is then a long minimal model).";
ECPIsMinimal::usage="ECPIsMinimal[{a1,a2,a3,a4,a6}] checks if the provided long model is mathematically minimal.\nAlso accepts short {A,B} (as {0,0,0,A,B}), an Association, an equation or Automatic.";
ECPIsMinimalShort::usage="ECPIsMinimalShort[{A, B}] checks if the short model is minimal.\nAlso accepts a long model, an Association, an equation or Automatic; for a long model this is the true Weierstrass minimality test (same as ECPIsMinimal).";

ECPTorsionSubgroup::usage="ECPTorsionSubgroup[curve] computes the torsion subgroup of an elliptic curve. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic. \"Points\" and \"Generators\" in the result are given back in that same curve's own coordinates; \"Order\" and \"Structure\" are unaffected by the choice of model.";
ECPFindTorsionPoints::usage="ECPFindTorsionPoints[curve] finds all rational torsion points using the Nagell-Lutz theorem (integral coordinates, and y = 0 or y^2 | Delta), returning them together with the point at Infinity. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic, and the returned points are given in that same curve's own coordinates. For non-integral A,B, or a discriminant too large to factor, it falls back to a bounded rational point search and issues a message, in which case the result is NOT guaranteed to be complete.";
ECPFindGenerators::usage="ECPFindGenerators[{A, B}, opts] finds independent generators for the elliptic curve.\nAlso accepts a curve in any form: the search runs on its integral short model and the generators and torsion points are returned in your own coordinates.";
ECPRankUpperBound::usage="ECPRankUpperBound[{A, B}] returns a heuristic, non-rigorous rank estimate based on the number of distinct prime factors of the discriminant (capped at 4). This is NOT a proven bound from 2-descent/Selmer group theory and can be wrong, especially for high-rank curves.\nAlso accepts a long model, an Association, an equation or Automatic (integral coefficients; the heuristic uses the discriminant of the model given).";
ECPPrimeDivisorCount::usage="ECPPrimeDivisorCount[n] returns nu(n), the number of distinct prime divisors of the nonzero integer n (nu(+-1) = 0).\nECPPrimeDivisorCount[curve] returns nu(Delta), the number of distinct primes dividing the discriminant of an integral model (short {A,B}, long {a1,a2,a3,a4,a6}, Association, equation or Automatic). A prime divides Delta of a minimal model exactly when the curve has bad reduction there.";
ECPRankBound::usage="ECPRankBound[curve] returns a PROVEN upper bound for the rank of E(Q), computed from prime-divisor counts (Lozano-Robledo, Theorem 2.6.4). It requires an integral model with a rational point of order 2. For y^2 = x^3 + a x^2 + b x it gives nu(a^2-4b) + nu(b) - 1; for any curve with a rational 2-torsion point it also gives m + 2 a - 1 (m, a = numbers of primes of multiplicative, additive bad reduction); if all three 2-torsion points are rational Proposition 2.9.1 gives 2 nu(Delta). The smallest bound is returned. If E(Q) has no point of order 2 no bound of this type exists and Missing[\"NoRational2Torsion\"] is returned (with a message).\nECPRankBound[curve, \"Details\"] returns an Association with keys \"Bound\", \"Candidates\" (method -> bound), \"TwoTorsionX\" and the data used.\nThe curve may be short {A,B}, long {a1,a2,a3,a4,a6}, an Association, an equation or Automatic, with integral coefficients. Unlike ECPRankUpperBound (a heuristic) this bound is a theorem; it is an upper bound only, not the rank.";
ECPSearchPoints::usage="ECPSearchPoints[curve, bound] searches for points on the curve within a numerical bound. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic, and returned points are given in that same curve's own coordinates.";
ECPOnCurveQ::usage="ECPOnCurveQ[P, curve] returns True if P (a point {x,y}, or Infinity) lies exactly on the given curve. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";
ECPTate::usage = "ECPTate[model, p] runs Tate's algorithm for an integral Weierstrass model {a1, a2, a3, a4, a6} at the prime p, returning an association containing the conductor exponent, Kodaira symbol, minimal model, and split type.";

ECPLocalData::usage = "ECPLocalData[model] returns an Association mapping each prime dividing the discriminant of the Weierstrass model to its local reduction data via Tate's algorithm.";

ECPConductor::usage = "ECPConductor[model] computes the conductor N of the elliptic curve given by the integral Weierstrass model.";

ECPAnalyticRank::usage = "ECPAnalyticRank[model, prec] computes the analytic rank, root number (sign of the functional equation) and conductor of the elliptic curve, returned as an Association with keys \"Rank\", \"Parity\" (the root number) and \"Conductor\"; the rank equals the true rank assuming the BSD conjecture. The optional parameter prec sets the working precision (default is 40).";

ECPNaiveHeight::usage="ECPNaiveHeight[P] computes the naive logarithmic height of a point.";
ECPCanonicalHeight::usage="ECPCanonicalHeight[P, curve, maxIter] computes the canonical height using iterative limits. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";
ECPHeightPairing::usage="ECPHeightPairing[P1, P2, curve] computes the Neron-Tate height pairing (1/2)(h(P1+P2)-h(P1)-h(P2)) of two points, so that ECPHeightPairing[P,P,curve] equals ECPCanonicalHeight[P,curve]. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";
ECPHeightMatrix::usage="ECPHeightMatrix[points, curve] computes the height pairing matrix (whose determinant is the regulator) for a given list of points. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";
ECPIndependentQ::usage="ECPIndependentQ[points, curve] checks if a set of points is independent based on their height matrix determinant, using a default tolerance of 0.01 (chosen because ECPCanonicalHeight's 8-iteration approximation can disagree with itself by roughly that much even for exactly-dependent points). ECPIndependentQ[points, curve, tol] lets you supply an explicit tolerance instead. curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation/polynomial, or Automatic.";

ECPAddFp::usage="ECPAddFp[P1, P2, curve, p] adds two points of the curve over F_p. curve may be short {A,B} (p odd), long {a1,a2,a3,a4,a6} (any prime p, including 2 and 3), an Association or an equation; the points are checked to lie on the curve. Either point may be Infinity (the point at infinity), which is also what the function returns for it.\nOver F_(p^r): ECPAddFp[P1, P2, curve, {p, r}] (see ECPFiniteFieldInfo for how field elements are written; the curve must be given in full).";
ECPMultiplyFp::usage="ECPMultiplyFp[n, P, curve, p] multiplies a point of the curve over F_p by the integer n (which may be negative). curve may be short {A,B} (p odd), long {a1,a2,a3,a4,a6} (any prime p, including 2 and 3), an Association or an equation; the point is checked to lie on the curve.\nOver F_(p^r): ECPMultiplyFp[n, P, curve, {p, r}].";
ECPPointQFp::usage="ECPPointQFp[P, curve, p] returns True if the point P (a point {x,y}, or Infinity) lies on the curve over the finite field F_p. curve may be given in any form and p may be any prime (a short pair {A,B} needs p odd). Coordinates are reduced mod p before comparison, so they need not already be in the range [0,p). Returns $Failed with a message if p is not prime.\nECPPointQFp[P, curve, {p, r}] works over F_(p^r).";
ECPGroupFp::usage="ECPGroupFp[curve, p] and ECPGroupFp[curve, {p, r}] compute the group E(F_q) of points of an elliptic curve over F_p or F_(p^r) (q = p^r, q <= $ECPFqTableLimit) and return an Association with keys \"Field\" ({p,r}), \"Curve\" (the long coefficients {a1,a2,a3,a4,a6} in field notation), \"Order\" (number of points, including the point at infinity), \"Invariants\" ({n1, n2} with n1 dividing n2, so that E(F_q) is isomorphic to Z/n1 x Z/n2), \"Structure\" (the same as a string), \"Generators\" (one point if the group is cyclic, two otherwise, none for the trivial group) and \"Points\" (every point, starting with Infinity). curve may be short {A,B}, long {a1,a2,a3,a4,a6}, a curve Association, an equation or Automatic. Over F_p elements are integers 0..p-1; over F_(p^r), r >= 2, they are written 0 or g^k (see ECPFiniteFieldInfo). Works in every characteristic, including 2 and 3.";
ECPFindPointOrderFp::usage="ECPFindPointOrderFp[point, curve, p] returns the order of a point on the curve over F_p, i.e. the smallest positive integer n with n*point = Infinity. curve may be given in any form and p may be any prime (a short pair {A,B} needs p odd). It first computes the group order N via ECPSEAPointCount (so it inherits that function's practical limit of p up to about 10^6), then returns the smallest divisor of N that annihilates the point, which is guaranteed to exist and to be correct by Lagrange's theorem. Returns $Failed (with a message) if p is not prime, the curve is singular mod p, the point is not on the curve, or p exceeds ECPSEAPointCount's limit.\nECPFindPointOrderFp[point, curve, {p, r}] works over F_(p^r) (q = p^r up to $ECPFqTableLimit, or any r when the coefficients are plain integers).";
ECPFindPointFp::usage="ECPFindPointFp[m, curve, p, kappa] embeds an integer message onto the curve using Koblitz encoding; kappa is optional (default 100) and curve may be given in any form (odd p). Requires m*kappa + kappa < p, or the embedding cannot be reliably decoded (the curve addition's mod-p reduction would destroy the information needed to recover m); this is checked and reported via a message.\nKoblitz embedding is for PRIME fields only: with {p, r}, r >= 2, a message says so ({p, 1} is treated as the prime p).";
ECPElGamalEncodeFp::usage="ECPElGamalEncodeFp[m, {pntP, pntB}, curve, p, n] performs ElGamal encryption/encoding; curve may be given in any form (odd p). ECPElGamalEncodeFp[m, {pntP, pntB}, curve, p, n, kappa] uses a non-default Koblitz padding parameter (must match the kappa passed to ECPElGamalDecodeFp). Prime fields only: with {p, r}, r >= 2, a message says so.";
ECPElGamalDecodeFp::usage="ECPElGamalDecodeFp[s, {C1, C2}, curve, p] performs ElGamal decryption/decoding, assuming the default Koblitz padding parameter (kappa = 100); curve may be given in any form (odd p). ECPElGamalDecodeFp[s, {C1, C2}, curve, p, kappa] must be used if encoding used a non-default kappa. Prime fields only: with {p, r}, r >= 2, a message says so.";
ECPSEAPointCount::usage="ECPSEAPointCount[curve, p] computes the exact number of points on the curve over F_p by direct O(p) character-sum enumeration. curve may be given in any form; a short pair {A,B} needs p odd, while a long model also works for p = 2 and 3. Despite the name, this is NOT the Schoof-Elkies-Atkins algorithm; it is practical only for p up to about 10^6. For larger primes use ECPSchoofPointCount, which implements Schoof's algorithm.\nECPSEAPointCount[curve, {p, r}] counts the points over F_(p^r): by enumeration for q up to $ECPFqTableLimit, and for a curve whose coefficients are plain integers by #E(F_p) and a Lucas sequence for ANY r (p up to 10^6).";
ECPSchoofPointCount::usage="ECPSchoofPointCount[curve, p] computes #E(F_p), the number of points including the point at infinity, by Schoof's algorithm: the trace of Frobenius t is found modulo small primes l from the action of the Frobenius endomorphism on the l-torsion (division polynomials, with arithmetic in F_p[x]/(psi_l)) and recovered with the Chinese Remainder Theorem and Hasse's bound. The running time is polynomial in log p, so primes far beyond the 10^6 limit of the enumeration in ECPSEAPointCount are practical. curve may be given in any form (short {A,B}, long {a1,a2,a3,a4,a6}, an Association or an equation) and p must be a prime; for p = 2 and 3 the points are counted directly. The Elkies and Atkin improvements of the SEA algorithm are not implemented.\nECPSchoofPointCount[a, b, p] is the short form y^2 = x^3 + a x + b, and ECPSchoofPointCount[curve, {p, 1}] is accepted as well.";

$ECPFqTableLimit::usage="$ECPFqTableLimit (default 10^60) is the largest field order q = p^r for which the discrete-log tables of F_q are built. Curve point counts over F_(p^r) for a curve whose coefficients are plain integers need no tables (they use #E(F_p) and a Lucas sequence) and are not limited by it.";
ECPFiniteFieldInfo::usage="ECPFiniteFieldInfo[{p, r}] describes the field F_(p^r) (r >= 2) used by every command that accepts {p, r}: its field polynomial f(x) over F_p and the meaning of the generator g (the class of x, a primitive element). Elements are written 0 and g^k, k = 0..q-2 (g^0 prints as 1); on input any polynomial in g with integer coefficients is accepted (e.g. 1 + g, 2 g^3 + 1, g^-1), an integer n means n mod p, and any single symbol may be used in place of g.";
ECPFqAdd::usage="ECPFqAdd[a, b, {p, r}] adds two elements of F_(p^r) (r >= 2); see ECPFiniteFieldInfo for how elements are written.";
ECPFqMultiply::usage="ECPFqMultiply[a, b, {p, r}] multiplies two elements of F_(p^r) (r >= 2).";
ECPFqInverse::usage="ECPFqInverse[a, {p, r}] is the multiplicative inverse of a nonzero element of F_(p^r) (r >= 2).";
ECPFqVector::usage="ECPFqVector[a, {p, r}] returns the coefficient list {c0, ..., c_(r-1)} over F_p with a = c0 + c1 g + ... + c_(r-1) g^(r-1).";
ECPFqElement::usage="ECPFqElement[{c0, ..., c_(r-1)}, {p, r}] is the inverse of ECPFqVector: it returns the element c0 + c1 g + ... + c_(r-1) g^(r-1) in the 0 / g^k notation.";

ECPParseAffineCurve::usage="ECPParseAffineCurve[input] normalises a curve given as a polynomial, an equation, a 5-element coefficient list, a curve Association, or Automatic (the session curve) into {polynomial, {xvar, yvar}}.";
ECPParseHomogeneousCurve::usage="ECPParseHomogeneousCurve[input] normalises a cubic into a homogeneous polynomial in 3 variables and returns that polynomial (use Variables[] for its variables). A 2-variable input is homogenised with respect to z automatically.\nShort {A,B} and Association inputs are also accepted.";
ECPExtractCoefficients::usage="ECPExtractCoefficients[curve] returns the long Weierstrass coefficients {a1,a2,a3,a4,a6} of a curve given in any of the forms accepted by ECPParseAffineCurve. Variables may be named x/y or X/Y.";
ECPWInvariants::usage="ECPWInvariants[{a1,a2,a3,a4,a6}] returns the Association <|\"b2\"->b2,\"b4\"->b4,\"b6\"->b6,\"b8\"->b8,\"c4\"->c4,\"c6\"->c6,\"Discriminant\"->\\[CapitalDelta]|>. (No j-invariant key -- compute c4^3/Discriminant yourself if you need it.)\nThe curve may also be given as short {A,B}, a curve Association, an equation/polynomial in x,y, or Automatic.";
ECPFormattedEquation::usage="ECPFormattedEquation[{a1,a2,a3,a4,a6}] returns the long Weierstrass equation y^2+a1 x y+a3 y == x^3+a2 x^2+a4 x+a6 as a displayable Equal expression.\nThe curve may also be given as short {A,B}, a curve Association, an equation/polynomial in x,y, or Automatic.";
ECPPolynomialHomogeneous::usage="ECPPolynomialHomogeneous[F, vars] returns True if F is homogeneous in vars (exact test, no numerical tolerance).";
ECPPolynomialTransform::usage="ECPPolynomialTransform[F, vars, matrix] substitutes the linear change of variables given by matrix into F and expands.";
ECPAreProjectivelyEquivalent::usage="ECPAreProjectivelyEquivalent[P, Q] returns True if the projective points P and Q are proportional. The zero vector is equivalent to nothing, not to everything.";
ECPChordAndTangent::usage="ECPChordAndTangent[P, curve, vars] returns the third intersection point of the tangent line to the cubic curve=0 at the projective point P with the curve (the chord-and-tangent doubling of P). curve and vars both default to Automatic (the session curve, with vars taken from Variables[curve]). If P is an inflection point, P itself is returned. The computation is an exact projective parametrisation, so it is chart-independent.";
ECPToWeierstrassForm::usage="ECPToWeierstrassForm[F, vars] normalises a cubic that is already in Weierstrass shape (y^2 + a1 x y + a3 y = x^3 + a2 x^2 + a4 x + a6, up to an overall scale) and returns the monic long Weierstrass polynomial y^2+a1 x y+a3 y-(x^3+a2 x^2+a4 x+a6); use ECPExtractCoefficients to read off {a1,a2,a3,a4,a6}. Stray non-Weierstrass monomials are reported with a message rather than discarded silently.";
ECPTransformWeierstrass::usage="ECPTransformWeierstrass[{a1,a2,a3,a4,a6}, {u,r,s,t}] applies the Weierstrass isomorphism x = u^2 x' + r, y = u^3 y' + u^2 s x' + t and returns the new coefficients.\nThe curve may also be given as short {A,B}, an Association, an equation or Automatic; the result is always the five long coefficients.";
ECPComposeTransformations::usage="ECPComposeTransformations[{u1,r1,s1,t1}, {u2,r2,s2,t2}] returns the single Weierstrass isomorphism equivalent to applying the first and then the second.";
ECPFindLocalReduction::usage="ECPFindLocalReduction[{a1,a2,a3,a4,a6}, p] returns the local Laska-Kraus reduction step at the prime p as {u,r,s,t}, or None if the model is already minimal at p.\nThe curve may be given in any accepted form (short, long, Association, equation, Automatic).";
$ECPNagellLutzDiscLimit::usage="$ECPNagellLutzDiscLimit (default 10^60) is the largest |discriminant| for which ECPFindTorsionPoints will run the exact Nagell-Lutz divisor enumeration. Above it, the function falls back to a bounded search and says so.";

ECPMillerFp::usage="ECPMillerFp[n, P, Q, curve, field] evaluates Miller's function f_{n,P} at the point Q by the double-and-add loop, where div f_{n,P} = n(P) - ([n]P) - (n-1)(O) normalised as in Miller's algorithm (the line through T and P divided by the vertical line through T+P at every step). field is a prime p or {p, r}; curve may be short {A,B} (p odd), long {a1,a2,a3,a4,a6}, an Association or an equation, and P, Q are points on it (elements over F_(p^r), r >= 2, are written 0 or g^k, see ECPFiniteFieldInfo). Q must not be Infinity. Returns $Failed with a message if Q is a zero or pole of an intermediate function (for example when Q lies in the group generated by P). Works in every characteristic, including 2 and 3.";
ECPWeilPairingFp::usage="ECPWeilPairingFp[n, P, Q, curve, field] computes the Weil pairing e_n(P,Q) = (-1)^n f_{n,P}(Q) / f_{n,Q}(P) of two points P, Q in E[n] (nP = nQ = Infinity) of a curve over F_p or F_(p^r), using Miller's algorithm for both functions. The result is an n-th root of unity in F_q, written as an integer for field p or {p,1} and as 0 or g^k for r >= 2. The pairing is bilinear, alternating (e_n(P,P) = 1) and non-degenerate. Points of order smaller than n are reduced to their exact order, and dependent points give 1. n must be prime to p. Returns $Failed with a message if a point is not on the curve or not in E[n].";
ECPTorsionBasisFp::usage="ECPTorsionBasisFp[n, curve, field] returns a basis {P, Q} of the full n-torsion subgroup E[n] contained in E(F_q), where field is a prime p or {p, r}: P has exact order n and ECPWeilPairingFp[n, P, Q, curve, field] is a primitive n-th root of unity. Requires E[n] to be contained in E(F_q) (the group must contain Z/n x Z/n) and n prime to p, otherwise a message explains why and $Failed is returned. The search enumerates all points, so q is limited by $ECPFqTableLimit.";

ECPTatePairingFp::usage="ECPTatePairingFp[n, P, Q, curve, field] computes the reduced Tate pairing t_n(P,Q) = f_{n,P}(Q)^((q-1)/n) by Miller's algorithm, where P is a point of E(F_q) with nP = Infinity, Q is any point of E(F_q) (the value depends only on Q modulo nE(F_q)) and n divides q - 1. field is a prime p or {p, r}; curve is in any accepted form (every characteristic). The result is an n-th root of unity in F_q (an integer for r = 1, 0 or g^k for r >= 2). It is bilinear and non-degenerate on E(F_q)[n] x E(F_q)/nE(F_q); a point P of smaller exact order is reduced to its order, and if Q is a zero or pole of an intermediate Miller function the value f(Q+S)/f(S) with an auxiliary point S is used. If n does not divide q - 1 a message asks for an extension field with n | p^r - 1. Unlike the Weil pairing, the pairing is not alternating and gives a nontrivial value for P = Q.";

ECPKodairaType::usage="ECPKodairaType[{ordC4, ordC6, ordDelta}] returns {type, EulerNumber} from Kodaira's table, where the arguments are the orders of vanishing of c4, c6 and Delta at a point (equivalently of f = -c4/48, g = -c6/864). The table is the characteristic-0 one, so it is valid over Q(t) and C(t). The Euler number of the fibre equals ordDelta. Returns {\"non-minimal\", Indeterminate} when ordC4 >= 4 and ordC6 >= 6, and {\"unclassified\", Indeterminate} for inconsistent orders.";
ECPFibreAt::usage="ECPFibreAt[curve, t, t0] classifies the fibre of the family of elliptic curves over Q(t) at t = t0 (t0 may be Infinity, see ECPFibreAtInfinity) by Kodaira's table, and returns an Association with keys \"Location\", \"Degree\", \"Type\", \"Euler\", \"Orders\" ({ord c4, ord c6, ord Delta}), \"Split\", \"SplitCriterion\", \"GaugeAlgebra\" and \"ScalingDimension\". curve is any accepted form (long {a1,a2,a3,a4,a6} with coefficients that are polynomials in t, short {A,B}, an equation in x,y, Association). The model must be minimal at t0 (otherwise the type is reported as \"non-minimal\"). \"Split\" is decided over Q for types I_n (n >= 1) and IV, by testing whether \"SplitCriterion\" (-c6 at the point for I_n, g/t^2 for IV) is a rational square; for symbolic models it is Missing[\"Symbolic\"] and \"SplitCriterion\" is the expression that must be a perfect square (the F-theory su(n) versus sp(n/2) condition). For other types it is Missing[\"NotApplicable\"].";
ECPFibreAtInfinity::usage="ECPFibreAtInfinity[curve, t] and ECPFibreAtInfinity[curve, t, n] classify the fibre at t = Infinity of a family over P^1 whose Weierstrass coefficients a_i have degree <= i n in t (n = 1 rational elliptic surface, n = 2 K3). The default n = Automatic is the smallest n that makes the model regular at infinity (from the degrees of c4, c6 and Delta); give n explicitly when you want a larger n than the degrees force. Returns the same Association as ECPFibreAt.";
ECPFibreList::usage="ECPFibreList[curve, t] and ECPFibreList[curve, t, n] return all singular fibres of the family over P^1: an Association with keys \"n\", \"Fibres\" (one record, as in ECPFibreAt, for every irreducible factor of the discriminant over Q, with \"Degree\" its number of points, plus the fibre at Infinity), \"TotalEuler\", \"ExpectedEuler\" (= 12 n) and \"ConsistentQ\" (True when the Euler numbers add up, a strong check that the model is minimal and the classification is right). For an irreducible factor of degree > 1 the \"Location\" is that polynomial (its roots all carry the same fibre type) and \"Split\" is Missing[\"NeedsExtension\"].";
ECPJFunction::usage="ECPJFunction[curve] returns the j-invariant c4^3/Delta of a family as a simplified rational function of its parameters (ECPJInvariant is meant for numeric curves; its singularity test cannot decide symbolic discriminants).";
ECPCoulombDimension::usage="ECPCoulombDimension[ordDelta] returns the scaling dimension 12/(12 - ordDelta) of the Coulomb-branch parameter at a Kodaira singularity with ord Delta = ordDelta (Argyres-Douglas / Minahan-Nemeschansky: II -> 6/5, III -> 4/3, IV -> 3/2, I0* -> 2, IV* -> 3, III* -> 4, II* -> 6). It is meaningful only for the non-I_n types, i.e. 2 <= ordDelta <= 10, ordDelta =/= 1 and not an I_n fibre.";
ECPGaugeAlgebra::usage="ECPGaugeAlgebra[type] and ECPGaugeAlgebra[type, split] give the F-theory gauge algebra for a Kodaira type string (\"I3\", \"IV*\", ...), with split = True or False where it matters (I_n: su(n) / sp(floor(n/2)); IV: su(3) / su(2); I_n*: so(2n+8) / so(2n+7); IV*: e6 / f4). III -> su(2), III* -> e7, II* -> e8, I2 -> su(2). I0* depends on the monodromy cover (so(8), so(7) or g2) and II, I0, I1 carry no gauge algebra. When split is omitted an unresolved case is returned as an \"either/or\" string.";
ECPTateForm::usage="ECPTateForm[ords, t] returns the long Weierstrass coefficients {a1,a2,a3,a4,a6} with a_i = (c_i + (i+1) t) t^ords[[i]] for the base constants c = {1,1,3,5,7}, i.e. a model whose a_i vanish to the prescribed orders at t = 0 (F-theory Tate form). Example orders: SU(2) {0,0,1,1,2}, SU(3) {0,1,1,2,3}, SU(5) {0,1,2,3,5}, SO(10) {1,1,2,3,5}, E6 {1,2,2,3,5}, E7 {1,2,3,3,5}, E8 {1,2,3,4,5}. The base constants are one arbitrary generic choice, not the most general Tate form.";
ECPTorsionFamily::usage="ECPTorsionFamily[N, d] returns the universal elliptic curve with a rational N-torsion point (Tate-Kubert normal form y^2 + (1-c) x y - b y = x^3 - b x^2, the point (0,0) has order N) as an Association with keys \"Coefficients\" ({1-c, -b, -b, 0, 0}), \"b\", \"c\" and \"Parameter\", for N = 4, 5, 6, 7 with the parameter d on X_1(N). Over the function field Q(d) the Mordell-Weil torsion contains Z/N; use ECPFibreList on the result to see the fibre content (N = 6 gives I6, I3, I2, I1).";

Begin["`Private`"];

(* 0. MESSAGES *)

ECPSetEC::badcoeff="ECPSetEC expects one list {a1,a2,a3,a4,a6} of 5 coefficients; received `1`.";
ECPack`$ECPCurrentEC::unset="No session curve has been set. Call ECPSetEC[{a1,a2,a3,a4,a6}] first, or pass the curve explicitly instead of Automatic.";

ECPShortWierstrass::badVars="Expected a curve in exactly 2 variables; found `1`.";

ECPJInvariant::singular="The curve `1` is singular (discriminant is 0).";

ECPExtractCoefficients::unset="No session curve has been set. Call ECPSetEC[{a1,a2,a3,a4,a6}] first, or pass the curve explicitly instead of Automatic.";

ECPLegendreToWeierstrass::degenerateLambda="lambda = `1` gives a singular curve (lambda must not be 0 or 1).";
ECPQuarticToWeierstrass::degenerateQuartic="The quartic {a,b,c,d,e}=`1` gives a singular curve.";

ECPNormalFormCharTwoThree::badChar="ECPNormalFormCharTwoThree only supports characteristic 2 or 3 (got `1`); use ECPToShortWeierstrass for other characteristics.";
ECPNormalFormCharTwoThree::singularCurve="The given coefficients define a singular curve over F_`1`.";

ECPCubicToWeierstrassCharTwoThree::badChar="ECPCubicToWeierstrassCharTwoThree only supports characteristic 2 or 3 (got `1`).";
ECPCubicToWeierstrassCharTwoThree::notOnCurve="The point `1` does not lie on the given curve over F_`2`.";
ECPCubicToWeierstrassCharTwoThree::singularPoint="The point `1` is a singular point of the curve over F_`2` (all partial derivatives vanish there).";
ECPCubicToWeierstrassCharTwoThree::notFlex="The point `1` is not an inflection point mod `2`: after moving it to [0:1:0] and its tangent line to {z=0}, the resulting cubic still has a nonzero X^2 Y, X Y^2, or Y^3 term.";
ECPCubicToWeierstrassCharTwoThree::noAuxPoint="Could not find an auxiliary point to complete the coordinate change. This should not happen for a genuine flex on a smooth cubic over F_`1`; double check the curve is smooth and P is really on it.";
ECPCubicToWeierstrassCharTwoThree::badVars="Could not identify exactly 3 variables in F (found `1`); pass a cubic in exactly 3 homogeneous variables.";

ECPChordAndTangent::notOnCurve="Point `1` does not lie on the curve `2`.";
ECPChordAndTangent::singularPoint="Point `1` is a singular point on the curve `2`.";
ECPChordAndTangent::badVars="Expected a homogeneous cubic in exactly 3 variables; found `1`.";
ECPChordAndTangent::badPoint="Expected a projective point {x,y,z}; received `1`.";
ECPChordAndTangent::noAuxPoint="Could not construct a second point on the tangent line at `1`.";
ECPChordAndTangent::lineInCurve="The tangent line at `1` is a component of the cubic `2`; the third intersection point is not well defined.";

ECPCubicToWeierstrass::notThreeVars="The expression `1` does not contain exactly 3 variables.";
ECPCubicToWeierstrass::notHomogeneous="The equation `1` is not homogeneous.";
ECPCubicToWeierstrass::notProjective="The coordinates `1` do not represent a valid 3D projective point.";
ECPCubicToWeierstrass::notOnCurve="Point `1` does not lie on the cubic curve `2`.";
ECPCubicToWeierstrass::singularPoint="Calculated point `1` is a singular point on `2`.";
ECPCubicToWeierstrass::zeroPoint="Transformation encountered a point at infinity with Z = 0.";
ECPCubicToWeierstrass::singularMatrix="Transformation matrix M is singular (Det = 0).";
ECPCubicToWeierstrass::zeroCubicCoeff="Transformation resulted in a zero coefficient for x^3.";
ECPCubicToWeierstrass::zeroQuadraticCoeff="Transformation resulted in a zero coefficient for y^2 z.";
ECPCubicToWeierstrass::linearDependence="The generated points P, P2, and P3 are linearly dependent.";
ECPCubicToWeierstrass::unsupportedAlgorithm="Algorithm option `1` is not implemented; only \"wolfram\" is currently supported. Proceeding with the default method.";

ECPToWeierstrassForm::notWeierstrass="The reduced affine cubic is not in Weierstrass shape; unexpected monomial(s) x^i y^j for {i,j} in `1`.";
ECPToWeierstrassForm::badScale="The reduced affine cubic has x^3 coefficient `1` and y^2 coefficient `2`; expected them to be negatives of one another.";

ECPMinimalModel::singularCurve="The coefficients `1` define a singular curve (discriminant 0); there is no minimal model.";
ECPMinimalModelShort::singularCurve="{A,B} = `1` defines a singular curve (discriminant 0); there is no minimal model.";
ECPIsMinimal::singularCurve="The coefficients `1` define a singular curve (discriminant 0).";
ECPIsMinimal::nonintegral="ECPIsMinimal requires integral coefficients; received `1`.";

ECPFindTorsionPoints::singular="The curve y^2 = x^3 + (`1`)x + (`2`) is singular (discriminant 0); it is not an elliptic curve.";
ECPFindTorsionPoints::nonintegral="Coefficients {A,B} = `1` are not both rational numbers, so the Nagell-Lutz theorem does not apply. Falling back to a bounded rational point search (|x| <= `2`, denominator <= 10); the result is NOT guaranteed to be the complete torsion subgroup.";
ECPFindTorsionPoints::bigdisc="|Discriminant| = `1` exceeds the factorisation limit `2` used for the Nagell-Lutz divisor enumeration. Falling back to a bounded rational point search; the result is NOT guaranteed to be the complete torsion subgroup.";

ECPTorsionSubgroup::badGroup="The `1` points found do not form a group of consistent order; the torsion computation is unreliable for this curve.";

ECPFindPointFp::outOfRange="Message `1` with kappa `2` is too large for field size `3`: need m*kappa + kappa < p, or the embedded x-coordinate can wrap modulo p and become undecodable.";
ECPFindPointFp::notprime="The field characteristic `1` is not a valid prime number.";
ECPFindPointFp::noPoint="Could not embed message `1` on the curve with kappa = `2`; try a larger kappa.";

ECPElGamalEncodeFp::embedFailed="Could not embed the message `1` onto the curve; encryption aborted.";
ECPElGamalEncodeFp::infinity="The ElGamal computation produced the point at infinity; choose a different random k or a base point of larger order.";
ECPElGamalDecodeFp::infinity="Decryption produced the point at infinity; the ciphertext, private key or curve parameters are inconsistent.";

ECPGroupFp::countMismatch="Internal consistency check failed: enumeration found `1` points but the point-counting routine gave `2`. Please report this curve.";
ECPGroupFp::structFail="Internal error while computing the group structure of the point set. Please report this curve.";
ECPSEAPointCount::notprime="The field characteristic `1` is not a valid prime number.";
ECPSEAPointCount::singular="The specified curve is singular. The discriminant (4 a^3 + 27 b^2) is 0 modulo `1`.";
ECPSEAPointCount::largep="p = `1` is too large for direct O(p) enumeration (limit 10^6). This function implements direct counting, not the SEA algorithm; use ECPSchoofPointCount (Schoof's algorithm) for larger primes.";

ECPPointQFp::notprime="The field characteristic `1` is not a valid prime number.";

ECPFindPointOrderFp::notprime="The field characteristic `1` is not a valid prime number.";
ECPFindPointOrderFp::notOnCurve="The point `1` does not lie on the curve y^2 = x^3 + (`2`)x + (`3`) modulo `4`.";
ECPFindPointOrderFp::noOrder="Could not determine a finite order for `1`; this should not happen for a point that lies on a nonsingular curve of known order.";

(* 0B. EXTRA MESSAGES *)

ECPSetEC::badtype="ECPSetEC expects five scalar coefficients {a1,a2,a3,a4,a6}; received `1`.";
ECPSetEC::singular="The coefficients `1` define a singular curve (discriminant 0), so it is not an elliptic curve. The session curve was NOT changed.";

ECPToShortWeierstrassFp::badcoeff="The coefficient(s) `1` cannot be reduced modulo `2`: each must be an integer, or a rational number whose denominator is not divisible by `2`.";

ECPNormalFormCharTwoThree::nonintegral="ECPNormalFormCharTwoThree needs integer coefficients (they are read modulo p); received `1`. ECPToShortWeierstrassFp also accepts rationals whose denominator is prime to p.";
ECPCubicToWeierstrassCharTwoThree::badPoint="The point `1` must be a list of three integers {x0,y0,z0}.";
ECPCubicToWeierstrassCharTwoThree::notPoly="The expression `1` is not a polynomial.";

ECPMinimalQ::nonintegral="The model `1` has non-integral coefficients, so it is not a minimal integral model; returning False.";
ECPMinimalQ::notprime="`1` is not a prime number.";
ECPMinimalModel::nonrational="ECPMinimalModel needs rational coefficients (integers or fractions); received `1`.";
ECPMinimalModelShort::nonintegral="{A,B} = `1` is not an integral pair, so no minimality reduction is attempted (ECPIsMinimal is reported as False).";

ECPSearchPoints::nonrational="ECPSearchPoints looks for rational points and needs rational A and B; received `1`.";
ECPPrimeDivisorCount::zero="ECPPrimeDivisorCount needs a nonzero integer; received `1`.";
ECPPrimeDivisorCount::nonintegral="ECPPrimeDivisorCount needs integral coefficients (it factors the discriminant); received `1`.";
ECPRankBound::nonintegral="ECPRankBound needs an integral model (integer coefficients); received `1`.";
ECPRankBound::no2tors="The curve `1` has no rational point of order 2, so the prime-divisor bound of Lozano-Robledo (Theorem 2.6.4) does not apply and no bound is returned. (Use ECPRankUpperBound for a non-rigorous heuristic estimate.)";
ECPRankBound::badopt="Unknown second argument `1`; the only accepted option is \"Details\".";
ECPRankUpperBound::nonintegral="ECPRankUpperBound needs integral coefficients (it factors the discriminant); received `1`.";

ECPFromMinimalPoint::zeroScale="The scaling factor u must be nonzero (the change of variables is not invertible for u = 0).";
ECPComposeTransformations::zeroScale="The scaling factor u must be nonzero (the change of variables is not invertible for u = 0).";
ECPTransformWeierstrass::zeroScale="The scaling factor u must be nonzero (the change of variables is not invertible for u = 0).";
ECPToMinimalPoint::zeroScale="The scaling factor u must be nonzero (the change of variables is not invertible for u = 0).";
ECPToLongCoordinates::zeroScale="The scaling factor u must be nonzero (the change of variables is not invertible for u = 0).";

ECPJInvariant::notprime="`1` is not a prime number.";
ECPJInvariant::nonintegral="The coefficients `1` must be integers to be reduced modulo p.";
ECPJInvariant::charTwoShort="y^2 = x^3 + A x + B is singular in characteristic 2 (no short Weierstrass form exists there), so the short-form j-invariant is undefined mod 2; use the long form {a1,a2,a3,a4,a6} with p = 2 instead.";

ECPSEAPointCount::charTwo="y^2 = x^3 + a x + b is singular in characteristic 2, so the character-sum count is not valid for p = 2.";

ecCurveMessages={
 "badcurve"->"Could not interpret `1` as an elliptic curve. Accepted forms: short {A,B}; long {a1,a2,a3,a4,a6}; an Association from ECPSetEC / ECPMinimalModel (keys \"Coefficients\", \"MinimalCoefficients\", or \"A\" and \"B\"); a Weierstrass equation or polynomial in x,y (or X,Y); or Automatic (the session curve).",
 "unset"->"The curve is Automatic but no session curve has been set. Call ECPSetEC[{a1,a2,a3,a4,a6}] first, or pass the curve explicitly.",
 "notWeierstrass"->"The equation is not in Weierstrass form: `1`.",
 "isSingular"->"The curve with coefficients `1` is singular (discriminant 0), so it is not an elliptic curve.",
 "badpoint"->"`1` is not a valid point: expected Infinity or a pair {x,y} of scalars.",
 "notOnCurve"->"The point `1` does not lie on the curve `2`."};

ecFpMessages={
 "notprime"->"The field characteristic `1` is not a valid prime number.",
 "charTwo"->"The short Weierstrass equation y^2 = x^3 + a x + b is always singular in characteristic 2 (received p = `1`), so the short-form formulas do not apply. Use ECPToShortWeierstrassFp[curve, 2] to obtain a model that is valid in characteristic 2.",
 "singularp"->"The curve `1` is singular modulo `2` (discriminant 0 in F_`2`), so it is not an elliptic curve over that field.",
 "badfppoint"->"`1` is not a valid point over F_p: expected Infinity or a pair {x,y} of integers.",
 "badcoord"->"The coordinates of `1` cannot be reduced modulo `2`: they must be integers, or rationals whose denominator is prime to p.",
 "notOnCurveP"->"The point `1` does not lie on the curve `2` over F_`3`.",
 "badcoeffp"->"The coefficient(s) `1` cannot be reduced modulo `2`: each must be an integer, or a rational number whose denominator is prime to p.",
 "koblitzOdd"->"Koblitz message embedding and ElGamal need an odd prime p (received p = `1`)."};

ecFqMessages={
 "badfield"->"`1` is not a valid finite field: pass a prime p, or {p, r} with p prime and r a positive integer.",
 "fieldTooBig"->"The field F_`1` is larger than $ECPFqTableLimit = `2`, so its arithmetic tables are not built. Raise $ECPFqTableLimit (memory grows linearly with q), or, for a curve with plain integer coefficients, use ECPSEAPointCount which needs no tables.",
 "badelem"->"`1` cannot be read as element(s) of F_`2`: write elements as 0, an integer (read mod p), or a Laurent polynomial in ONE symbol g with integer coefficients, e.g. g^5, 1 + g, 2 g^3 + 1.",
 "badfqpoint"->"`1` is not a valid point: expected Infinity or a pair {x, y} of field elements.",
 "singularq"->"The curve `1` is singular over F_`2` (discriminant 0 in that field), so it is not an elliptic curve there. (y^2 = x^3 + A x + B is always singular in characteristic 2.)",
 "extOnly"->"`1` needs an extension field {p, r} with r >= 2; for r = 1 use ordinary integer arithmetic mod p.",
 "zeroInverse"->"0 has no multiplicative inverse.",
 "badvector"->"`1` is not a list of `2` integers.",
 "fqKoblitz"->"Koblitz message embedding and ElGamal encode/decode are implemented for PRIME fields only (received the field `1`); a message integer has no canonical embedding into F_(p^r). Use {p, 1} or a prime p."};

ECPNormalFormCharTwoThree::noSolve="Could not complete the reduction over F_`1` (internal error).";
ECPCubicToWeierstrassCharTwoThree::notCubic="The polynomial `1` is not a homogeneous cubic form in x, y, z.";

ecFqFuncs={ECPTatePairingFp,ECPMillerFp,ECPWeilPairingFp,ECPTorsionBasisFp,ECPGroupFp,ECPAddFp,ECPMultiplyFp,ECPFindPointFp,ECPElGamalEncodeFp,ECPElGamalDecodeFp,ECPSEAPointCount,ECPPointQFp,ECPFindPointOrderFp,
 ECPToShortWeierstrassFp,ECPToShortCoordinatesFp,ECPFromShortCoordinatesFp,ECPNormalFormCharTwoThree,ECPCubicToWeierstrassCharTwoThree,
 ECPJInvariant,ECPFiniteFieldInfo,ECPFqAdd,ECPFqMultiply,ECPFqInverse,ECPFqVector,ECPFqElement};

ecArgMessages={
 "args"->"Invalid arguments (`1` given): `2`. Type ?`3` to see the accepted forms.",
 "badarg"->"Invalid `1`: expected `2`, received `3`."};

ecCurveFuncs={ECPBachetDuplication,ECPExtractCoefficients,ECPToShortWeierstrass,ECPShortWierstrass,ECPToShortCoordinates,ECPFromShortCoordinates,
 ECPWeierstrassDiscriminant,ECPShortDiscriminant,ECPAdd,ECPMultiply,ECPFindPointOrder,ECPOnCurveQ,
 ECPSearchPoints,ECPFindTorsionPoints,ECPTorsionSubgroup,ECPCanonicalHeight,ECPHeightPairing,ECPHeightMatrix,
 ECPIndependentQ,ECPFindGenerators,ECPRankUpperBound,ECPMinimalQ,ECPMinimalModel,ECPMinimalModelShort,ECPIsMinimal,ECPIsMinimalShort,
 ECPPointQ,ECPToShortWeierstrassFp,ECPToShortCoordinatesFp,ECPFromShortCoordinatesFp,
 ECPWInvariants,ECPFormattedEquation,ECPTransformWeierstrass,ECPFindLocalReduction,ECPNormalFormCharTwoThree,ECPJInvariant,ECPParseHomogeneousCurve,ECPToLongCoordinates,ECPToMinimalPoint,ECPFromMinimalPoint,
 ECPNaiveHeight,ECPShortDiscriminant,ECPComposeTransformations};

ecFpFuncs={ECPSchoofPointCount,ECPAddFp,ECPMultiplyFp,ECPFindPointFp,ECPElGamalEncodeFp,ECPElGamalDecodeFp,ECPSEAPointCount,ECPPointQFp,ECPFindPointOrderFp,
 ECPToShortWeierstrassFp,ECPToShortCoordinatesFp,ECPFromShortCoordinatesFp};

ecCatchAllFuncs={ECPSchoofPointCount,ECPTatePairingFp,ECPMillerFp,ECPWeilPairingFp,ECPTorsionBasisFp,ECPBachetDuplication,ECPGroupFp,ECPTate,ECPLocalData,ECPConductor,ECPAnalyticRank,ECPShortWierstrass,ECPShortWeierstrassForm,ECPShortDiscriminant,ECPJInvariant,ECPPointQ,
 ECPChordAndTangent,ECPCubicToWeierstrass,ECPPolynomialTransform,ECPPolynomialHomogeneous,ECPAreProjectivelyEquivalent,ECPToWeierstrassForm,ECPParseAffineCurve,
 ECPExtractCoefficients,ECPToShortWeierstrass,ECPToShortCoordinates,ECPFromShortCoordinates,
 ECPWeierstrassDiscriminant,ECPAdd,ECPMultiply,ECPFindPointOrder,ECPOnCurveQ,ECPSearchPoints,
 ECPFindTorsionPoints,ECPTorsionSubgroup,ECPCanonicalHeight,ECPHeightPairing,ECPHeightMatrix,ECPIndependentQ,
 ECPFindGenerators,ECPRankUpperBound,ECPMinimalQ,ECPMinimalModel,ECPMinimalModelShort,ECPIsMinimal,ECPIsMinimalShort,ECPNaiveHeight,
 ECPToShortWeierstrassFp,ECPToShortCoordinatesFp,ECPFromShortCoordinatesFp,ECPNormalFormCharTwoThree,
 ECPCubicToWeierstrassCharTwoThree,ECPLegendreToWeierstrass,ECPQuarticToWeierstrass,ECPSEAPointCount,ECPPointQFp,ECPFindPointOrderFp,
 ECPAddFp,ECPMultiplyFp,ECPFindPointFp,ECPElGamalEncodeFp,ECPElGamalDecodeFp,ECPToLongCoordinates,
 ECPToMinimalPoint,ECPFromMinimalPoint,ECPTransformWeierstrass,ECPComposeTransformations,ECPWInvariants,ECPFormattedEquation,ECPFindLocalReduction,
 ECPFiniteFieldInfo,ECPFqAdd,ECPFqMultiply,ECPFqInverse,ECPFqVector,ECPFqElement};

ecInstallMessages[funcs_List,table_List]:=
 Do[Scan[Function[rule,With[{sym=f,tag=First[rule],txt=Last[rule]},MessageName[sym,tag]=txt]],table],{f,funcs}];

ecInstallMessages[ecCurveFuncs,ecCurveMessages];
ecInstallMessages[ecFpFuncs,ecFpMessages];
ecInstallMessages[ecFqFuncs,ecFqMessages];
ecInstallMessages[ecCatchAllFuncs,ecArgMessages];

ecModelMessages={
 "badmodel"->"`1` is not an integral Weierstrass model: expected a list {a1,a2,a3,a4,a6} of five integers.",
 "singularmodel"->"The model `1` is singular (discriminant 0), so it is not an elliptic curve.",
 "badprime"->"`1` is not a prime number.",
 "badprec"->"The working precision `1` is too small: it must be an integer >= 20.",
 "tatefail"->"Tate's algorithm did not terminate normally for the model `1`; the local data could not be computed."};
ecInstallMessages[{ECPTate,ECPLocalData,ECPConductor,ECPAnalyticRank},ecModelMessages];

(* 0C. SHARED VALIDATION HELPERS *)

ecMsg[f_,tag_String,args___]:=Message[MessageName[f,tag],args];

ecBadArgs[f_,args_List]:=(Message[MessageName[f,"args"],Length[args],Short[args,2],SymbolName[f]];$Failed);

ecInstallCatchAll[f_Symbol]:=(f[args___]:=ecBadArgs[f,{args}]);

ecScalarQ[x_]:=!(ListQ[x]||AssociationQ[x]||StringQ[x]||x===Null||x===$Failed||x===True||x===False||
   MatchQ[x,_Missing|_Rule|_RuleDelayed|_DirectedInfinity|Indeterminate|ComplexInfinity]);

ecExactQ[x_]:=NumericQ[x]&&Precision[x]===Infinity;

ecZeroQ[x_]:=If[MatchQ[x,_Integer|_Rational],x===0,ecExactQ[x]&&TrueQ[Simplify[x]==0]];

ecPointShapeQ[P_]:=P===Infinity||(MatchQ[P,{_,_}]&&ecScalarQ[P[[1]]]&&ecScalarQ[P[[2]]]);

ecDisc[{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2,b4,b6,b8},
  b2=a1^2+4*a2;b4=2*a4+a1*a3;b6=a3^2+4*a6;
  b8=a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2;
  -b2^2*b8-8*b4^3-27*b6^2+9*b2*b4*b6];

c4Of[{a1_,a2_,a3_,a4_,a6_}]:=(a1^2+4*a2)^2-24*(2*a4+a1*a3);
c6Of[{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2=a1^2+4*a2,b4=2*a4+a1*a3,b6=a3^2+4*a6},-b2^3+36*b2*b4-216*b6];

ecShortChecks[{A_,B_},f_]:=Which[
  !(ecScalarQ[A]&&ecScalarQ[B]),(ecMsg[f,"badcurve",{A,B}];False),
  ecExactQ[A]&&ecExactQ[B]&&ecZeroQ[4*A^3+27*B^2],(ecMsg[f,"isSingular",{0,0,0,A,B}];False),
  True,True];
ecShortChecks[curve_,f_]:=(ecMsg[f,"badcurve",curve];False);

ecOnShortQ[{x_,y_},{A_,B_}]:=Module[{v=y^2-(x^3+A*x+B)},
  If[MatchQ[v,_Integer|_Rational],v===0,TrueQ[Simplify[v]==0]]];

ecOnLongQ[{x_,y_},{a1_,a2_,a3_,a4_,a6_}]:=Module[{v=y^2+a1*x*y+a3*y-(x^3+a2*x^2+a4*x+a6)},
  If[MatchQ[v,_Integer|_Rational],v===0,TrueQ[Simplify[v]==0]]];

(* membership is only tested when everything is exact; symbolic input is accepted as is *)
ecCheckOnLong[P_,c_,f_]:=If[AllTrue[Join[P,c],ecExactQ]&&!ecOnLongQ[P,c],(ecMsg[f,"notOnCurve",P,ECPFormattedEquation[c]];False),True];

ecToShortCore[Infinity,_]:=Infinity;
ecToShortCore[{x_,y_},{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2=a1^2+4*a2},{Simplify[x+b2/12],Simplify[y+(a1*x+a3)/2]}];
ecFromShortCore[Infinity,_]:=Infinity;
ecFromShortCore[{X_,Y_},{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2=a1^2+4*a2,xl},xl=Simplify[X-b2/12];{xl,Simplify[Y-(a1*xl+a3)/2]}];

ecTransOK[T_,f_]:=Which[
  !(MatchQ[T,{_,_,_,_}]&&AllTrue[T,ecScalarQ]),(ecMsg[f,"badarg","transformation {u,r,s,t}","a list of four scalars",T];False),
  TrueQ[T[[1]]==0],(ecMsg[f,"zeroScale"];False),
  True,True];

ecTolOK[tol_,f_]:=If[NumericQ[tol]&&tol>0,True,(ecMsg[f,"badarg","tolerance","a positive number",tol];False)];

ecGenOptsOK[opts_List,bound_,verbose_]:=Module[{bad=Complement[Keys[Flatten[opts]],{"SearchBound","Verbose"}]},
  Which[
   bad=!={},(ecMsg[ECPFindGenerators,"badarg","option name","\"SearchBound\" or \"Verbose\"",bad];False),
   !(IntegerQ[bound]&&bound>0),(ecMsg[ECPFindGenerators,"badarg","option \"SearchBound\"","a positive integer",bound];False),
   !BooleanQ[verbose],(ecMsg[ECPFindGenerators,"badarg","option \"Verbose\"","True or False",verbose];False),
   True,True]];

ecSession[f_]:=If[AssociationQ[ECPack`$ECPCurrentEC]&&KeyExistsQ[ECPack`$ECPCurrentEC,"Coefficients"],
  ECPack`$ECPCurrentEC["Coefficients"],
  (ecMsg[f,"unset"];$Failed)];

ecExtractAssoc[curve_Association,f_]:=Which[
  KeyExistsQ[curve,"Coefficients"]&&MatchQ[curve["Coefficients"],{_,_,_,_,_}],curve["Coefficients"],
  KeyExistsQ[curve,"MinimalCoefficients"]&&MatchQ[curve["MinimalCoefficients"],{_,_,_,_,_}],curve["MinimalCoefficients"],
  KeyExistsQ[curve,"MinimalCoefficients"]&&MatchQ[curve["MinimalCoefficients"],{_,_}],
    {0,0,0,curve["MinimalCoefficients"][[1]],curve["MinimalCoefficients"][[2]]},
  KeyExistsQ[curve,"A"]&&KeyExistsQ[curve,"B"],{0,0,0,curve["A"],curve["B"]},
  True,(ecMsg[f,"badcurve",curve];$Failed)];

ecExtract[curve_,f_]:=Which[
  curve===Automatic,ecSession[f],
  MatchQ[curve,{_,_}],
   If[ecScalarQ[curve[[1]]]&&ecScalarQ[curve[[2]]],{0,0,0,curve[[1]],curve[[2]]},(ecMsg[f,"badcurve",curve];$Failed)],
  MatchQ[curve,{_,_,_,_,_}],
   If[AllTrue[curve,ecScalarQ],curve,(ecMsg[f,"badcurve",curve];$Failed)],
  AssociationQ[curve],ecExtractAssoc[curve,f],
  True,ecExtractExpr[curve,f]];

ecExtractExpr[curve_,f_]:=Module[{expr,xSym,ySym,rules,allowed,stray,cf,cy2,cx3},
  If[!(Head[curve]===Equal||(!AtomQ[curve]&&Variables[curve]=!={}&&PolynomialQ[curve,Variables[curve]])),
   ecMsg[f,"badcurve",curve];Return[$Failed]];
  expr=Expand[If[Head[curve]===Equal,curve[[1]]-curve[[2]],curve]];
  If[Variables[expr]==={},
   ecMsg[f,"notWeierstrass","the expression contains no variables"];Return[$Failed]];
  {xSym,ySym}=detectXY[expr];
  If[!PolynomialQ[expr,{xSym,ySym}],
   ecMsg[f,"notWeierstrass","it is not a polynomial in "<>ToString[xSym]<>" and "<>ToString[ySym]];Return[$Failed]];
  rules=CoefficientRules[expr,{xSym,ySym}];
  allowed={{0,0},{1,0},{2,0},{3,0},{0,1},{1,1},{0,2}};
  stray=Complement[rules[[All,1]],allowed];
  If[stray=!={},
   ecMsg[f,"notWeierstrass","unexpected monomial(s) x^i y^j for {i,j} in "<>ToString[stray]<>
     " (a Weierstrass equation contains only y^2, x y, y, x^3, x^2, x and a constant)"];
   Return[$Failed]];
  cf[i_,j_]:=Coefficient[Coefficient[expr,xSym,i],ySym,j];
  cy2=cf[0,2];
  If[TrueQ[Simplify[cy2]==0],
   ecMsg[f,"notWeierstrass","there is no y^2 term (for y^2 = quartic use ECPQuarticToWeierstrass; for a general cubic use ECPCubicToWeierstrass)"];
   Return[$Failed]];

  expr=Expand[expr/cy2];
  cx3=cf[3,0];
  If[!TrueQ[Simplify[cx3+1]==0],
   ecMsg[f,"notWeierstrass","with the y^2 coefficient scaled to 1, the x^3 coefficient on the right-hand side is "<>
     ToString[-cx3,InputForm]<>", not 1, so the coefficients {a1..a6} cannot be read off. Substitute x -> X/k, y -> Y/k with k = "<>
     ToString[-cx3,InputForm]<>" (this makes x^3 monic and gives an isomorphic curve whose points have scaled coordinates), then retry"];
   Return[$Failed]];
  {cf[1,1],-cf[2,0],cf[0,1],-cf[1,0],-cf[0,0]}];

ecResolveCurve[curve_,f_]:=Module[{c,A,B},
  If[MatchQ[curve,{_,_}],
   Return[If[ecShortChecks[curve,f],{curve,False,curve},{$Failed,False,curve}]]];
  If[AssociationQ[curve]&&KeyExistsQ[curve,"A"]&&KeyExistsQ[curve,"B"],
   Return[If[ecShortChecks[{curve["A"],curve["B"]},f],
     {{curve["A"],curve["B"]},False,curve},{$Failed,False,curve}]]];
  If[AssociationQ[curve]&&KeyExistsQ[curve,"MinimalCoefficients"]&&MatchQ[curve["MinimalCoefficients"],{_,_}],
   Return[If[ecShortChecks[curve["MinimalCoefficients"],f],
     {curve["MinimalCoefficients"],False,curve},{$Failed,False,curve}]]];
  c=ecExtract[curve,f];
  If[c===$Failed,Return[{$Failed,False,curve}]];
  If[AllTrue[c,ecExactQ]&&ecZeroQ[ecDisc[c]],ecMsg[f,"isSingular",c];Return[{$Failed,False,curve}]];
  If[TrueQ[c[[1]]==0]&&TrueQ[c[[2]]==0]&&TrueQ[c[[3]]==0],Return[{{c[[4]],c[[5]]},False,c}]];
  A=Simplify[-c4Of[c]/48];B=Simplify[-c6Of[c]/864];
  {{A,B},True,c}];

ecPrepPoint[P_,ab_,needsT_,origC_,f_]:=Module[{Q},
  If[!ecPointShapeQ[P],ecMsg[f,"badpoint",P];Return[$Failed]];
  Q=If[TrueQ[needsT]&&P=!=Infinity,ecToShortCore[P,origC],P];
  If[Q===$Failed,Return[$Failed]];
  If[Q=!=Infinity&&ecExactQ[Q[[1]]]&&ecExactQ[Q[[2]]]&&ecExactQ[ab[[1]]]&&ecExactQ[ab[[2]]]&&!ecOnShortQ[Q,ab],
   ecMsg[f,"notOnCurve",P,If[TrueQ[needsT],origC,ab]];Return[$Failed]];
  Q];

(* 1. SESSION CURVE *)

ECPack`$ECPCurrentEC = <||>;

ECPSetEC[{a1_,a2_,a3_,a4_,a6_}]:=Module[{eq,xs,ys},
  If[!AllTrue[{a1,a2,a3,a4,a6},ecScalarQ],Message[ECPSetEC::badtype,{a1,a2,a3,a4,a6}];Return[$Failed]];
  If[AllTrue[{a1,a2,a3,a4,a6},ecExactQ]&&ecZeroQ[ecDisc[{a1,a2,a3,a4,a6}]],
    Message[ECPSetEC::singular,{a1,a2,a3,a4,a6}];Return[$Failed]];
  xs=Symbol["x"]; ys=Symbol["y"];
  eq=ys^2+a1*xs*ys+a3*ys-(xs^3+a2*xs^2+a4*xs+a6)==0;
  ECPack`$ECPCurrentEC=<|"Coefficients"->{a1,a2,a3,a4,a6},"Equation"->eq|>;
  Print["Session curve set to: ",eq];
  ECPack`$ECPCurrentEC];

(* FIX: the documented call form ECPSetEC[a1, a2, a3, a4, a6] *)
ECPSetEC[a1_,a2_,a3_,a4_,a6_]:=ECPSetEC[{a1,a2,a3,a4,a6}];
ECPSetEC[args___]:=(Message[ECPSetEC::badcoeff,{args}];$Failed);

sessionCoefficients[]:=If[AssociationQ[ECPack`$ECPCurrentEC]&&KeyExistsQ[ECPack`$ECPCurrentEC,"Coefficients"],
  ECPack`$ECPCurrentEC["Coefficients"],
  Message[ECPExtractCoefficients::unset];$Failed];

(* 2. VARIABLE DETECTION HELPERS *)

namedQ[s_,names_List]:=MatchQ[s,_Symbol]&&MemberQ[names,SymbolName[s]];

detectXY[expr_]:=Module[{vs,xs,ys},
  vs=Variables[expr];
  xs=SelectFirst[vs,namedQ[#,{"x","X"}]&];
  ys=SelectFirst[vs,namedQ[#,{"y","Y"}]&];
  Which[
    Head[xs]=!=Missing&&Head[ys]=!=Missing,{xs,ys},
    Length[vs]>=2,If[Exponent[expr,vs[[1]]]>=3,{vs[[1]],vs[[2]]},{vs[[2]],vs[[1]]}],
    Length[vs]==1,{vs[[1]],Symbol["y"]},
    True,{Symbol["x"],Symbol["y"]}]];

(* FIX: Variables[] does not guarantee the order x, y, z (it returned {x, z, y} for some cubics), and the
   coordinates of a projective point are read in that order. The roles are now fixed by name: x/X, y/Y, z/Z
   when exactly those three occur, otherwise alphabetical order of the symbol names. *)
ecOrderedVars[expr_]:=Module[{vs=Variables[expr],named},
  named=Select[vs,namedQ[#,{"x","y","z","X","Y","Z"}]&];
  If[Length[named]==3&&Length[vs]==3,SortBy[named,ToLowerCase[SymbolName[#]]&],SortBy[vs,{SymbolName[#],Context[#]}&]]];

(* 3. POINT MEMBERSHIP *)

ECPPointQ[{x1_,y1_},F_]:=Module[{raw,expr,xs,ys},
  If[AssociationQ[F]&&!KeyExistsQ[F,"Equation"],ecMsg[ECPPointQ,"badcurve",F];Return[$Failed]];
  If[!(ecScalarQ[x1]&&ecScalarQ[y1]),ecMsg[ECPPointQ,"badpoint",{x1,y1}];Return[$Failed]];
  raw=If[AssociationQ[F],F["Equation"],F];
  expr=Which[Head[raw]===Equal,raw[[1]]-raw[[2]],
    MatchQ[raw,{_,_,_,_,_}],ecAffinePoly[raw],
    MatchQ[raw,{_,_}],ecAffinePoly[{0,0,0,raw[[1]],raw[[2]]}],
    True,raw];
  If[ListQ[expr]||AssociationQ[expr]||StringQ[expr]||Variables[expr]==={}||!PolynomialQ[expr,Variables[expr]],
    ecMsg[ECPPointQ,"badcurve",F];Return[$Failed]];
  {xs,ys}=detectXY[expr];
  TrueQ[Simplify[expr/.{xs->x1,ys->y1}]==0]];

(* FIX: documented call form ECPPointQ[F, x1, y1] *)
ECPPointQ[F_,x1_,y1_]:=ECPPointQ[{x1,y1},F];

(* 4. SHORT WEIERSTRASS CONVERSIONS *)

ECPShortWeierstrassForm[curve_]:=ECPShortWierstrass[curve];

ECPShortWierstrass[curve_]:=Block[{expr,c0,vars,xv,yv,CC1,CC2,CC3,CC4,CC5,vv,uu,ww,ca1,ca3,cx2},
  c0=ecLong[curve,ECPShortWierstrass];
  If[c0===$Failed,Return[$Failed]];
  expr=Which[
    ListQ[curve]||AssociationQ[curve]||curve===Automatic,ecAffinePoly[c0],
    Head[curve]===Equal,curve[[1]]-curve[[2]],
    True,curve];
  expr=Expand[expr];
  vars=Variables[expr];
  If[Length[vars]=!=2,Message[ECPShortWierstrass::badVars,vars];Return[$Failed]];
  {xv,yv}=detectXY[expr];
  ca1=Coefficient[Coefficient[expr,xv],yv];
  ca3=Coefficient[Coefficient[expr,yv],xv,0];
  CC1=Simplify[expr/.yv->(vv-ca1*xv-ca3)/2];
  cx2=Coefficient[4*CC1,xv,2];
  CC2=Simplify[CC1/.xv->(ww+3*cx2)/36];
  CC3=Simplify[CC2/.vv->uu/108];
  CC4=CC3/.uu->yv;
  CC5=CC4/.ww->xv;
  Simplify[432*108*CC5]];

ECPToShortCoordinates[Infinity,curve_:Automatic]:=If[ecLong[curve,ECPToShortCoordinates]===$Failed,$Failed,Infinity];

ECPToShortCoordinates[{x_,y_},curve_:Automatic]:=Module[{c},
If[!(ecScalarQ[x]&&ecScalarQ[y]),ecMsg[ECPToShortCoordinates,"badpoint",{x,y}];Return[$Failed]];
c=ecLong[curve,ECPToShortCoordinates];
If[c===$Failed,Return[$Failed]];
If[!ecCheckOnLong[{x,y},c,ECPToShortCoordinates],Return[$Failed]];
ecToShortCore[{x,y},c]];
ECPToShortWeierstrass[curve_]:=Module[{c,a1,a2,a3,a4,a6,b2,b4,b6,c4,c6,A,B,X,Y},c=ecExtract[curve,ECPToShortWeierstrass];
If[c===$Failed,Return[$Failed]];
If[AllTrue[c,ecExactQ]&&ecZeroQ[ecDisc[c]],ecMsg[ECPToShortWeierstrass,"isSingular",c];Return[$Failed]];
{a1,a2,a3,a4,a6}=c;
b2=a1^2+4*a2;
b4=2*a4+a1*a3;
b6=a3^2+4*a6;
c4=b2^2-24*b4;
c6=-b2^3+36*b2*b4-216*b6;
A=Simplify[-c4/48];
B=Simplify[-c6/864];
With[{xs=Symbol["X"],ys=Symbol["Y"]},ys^2==xs^3+A*xs+B]];

ECPLegendreToWeierstrass[lambda_]:=Module[{A,B},
  If[!ecScalarQ[lambda],ecMsg[ECPLegendreToWeierstrass,"badarg","lambda","a scalar",lambda];Return[$Failed]];
  If[TrueQ[lambda==0]||TrueQ[lambda==1],Message[ECPLegendreToWeierstrass::degenerateLambda,lambda];Return[$Failed]];
  A=-432*(lambda^2-lambda+1);
  B=-1728*(1+lambda)*(lambda-2)*(2*lambda-1);
  {A,B}];

ECPQuarticToWeierstrass[{a_,b_,c_,d_,e_}]:=Module[{IInv,JInv,A,B},
  If[!AllTrue[{a,b,c,d,e},ecScalarQ],ecMsg[ECPQuarticToWeierstrass,"badarg","quartic coefficients {a,b,c,d,e}","five scalars",{a,b,c,d,e}];Return[$Failed]];
  IInv=12*a*e-3*b*d+c^2;
  JInv=72*a*c*e+9*b*c*d-27*a*d^2-27*e*b^2-2*c^3;
  A=-27*IInv;
  B=-27*JInv;
  If[TrueQ[Simplify[4*A^3+27*B^2]==0],Message[ECPQuarticToWeierstrass::degenerateQuartic,{a,b,c,d,e}];Return[$Failed]];
  {A,B}];

ECPNormalFormCharTwoThree[coeffs:{_,_,_,_,_},p_Integer]:=Module[
{a1,a2,a3,a4,a6,disc,u=1,r,s,t,b2,newCoeffs,case},
If[p!=2&&p!=3,Message[ECPNormalFormCharTwoThree::badChar,p];Return[$Failed]];
If[!AllTrue[coeffs,IntegerQ],Message[ECPNormalFormCharTwoThree::nonintegral,coeffs];Return[$Failed]];
{a1,a2,a3,a4,a6}=Mod[coeffs,p];
disc=Mod[ecDisc[{a1,a2,a3,a4,a6}],p];
If[disc==0,Message[ECPNormalFormCharTwoThree::singularCurve,p];Return[$Failed]];
Which[
p==2,
If[Mod[a1,2]!=0,

u=1;r=Mod[a3*PowerMod[a1,-1,p],p];s=0;t=Mod[(a4+r^2)*PowerMod[a1,-1,p],p];
case="ordinary (a1 != 0): y^2+xy=x^3+a2 x^2+a6",

u=1;s=0;r=Mod[a2,p];t=0;
case="supersingular (a1 = 0): y^2+a3 y=x^3+a4 x+a6"
],
p==3,

s=Mod[a1,3];
b2=Mod[a1^2+4*a2,3];
If[b2!=0,
r=Mod[-(a4+2*a1*a3)*PowerMod[2*b2,-1,p],p];
case="ordinary (b2 != 0): y^2=x^3+a2 x^2+a6",
r=0;
case="supersingular (b2 = 0): y^2=x^3+a4 x+a6"
];
t=Mod[a3+r*a1,3];
];
newCoeffs=Mod[ECPTransformWeierstrass[{a1,a2,a3,a4,a6},{u,r,s,t}],p];
<|"NormalForm"->newCoeffs,"Transformation"->{u,r,s,t},"Case"->case,"Characteristic"->p|>
];

ECPCubicToWeierstrassCharTwoThree[P_List,F_,p_Integer]:=Module[
{vars,xVar,yVar,zVar,Xs,Ys,Zs,Fx,Fy,Fz,Amod,Bmod,Cmod,Pmod,onLineQ,canonPt,Pcanon,
candidates,Q,R,Mp,newVarsOld,H,cYYZ,cXXX,k1,k2,a1,a2,a3,a4,a6,badTerm},
If[p!=2&&p!=3,Message[ECPCubicToWeierstrassCharTwoThree::badChar,p];Return[$Failed]];
If[!(Length[P]==3&&AllTrue[P,IntegerQ]),Message[ECPCubicToWeierstrassCharTwoThree::badPoint,P];Return[$Failed]];
If[!(Variables[F]=!={}&&PolynomialQ[F,Variables[F]]),Message[ECPCubicToWeierstrassCharTwoThree::notPoly,F];Return[$Failed]];
vars=ecOrderedVars[F];
If[Length[vars]!=3,Message[ECPCubicToWeierstrassCharTwoThree::badVars,vars];Return[$Failed]];
{xVar,yVar,zVar}=vars;
Pmod=Mod[P,p];
If[Mod[F/.Thread[vars->Pmod],p]!=0,
Message[ECPCubicToWeierstrassCharTwoThree::notOnCurve,Pmod,p];Return[$Failed]];
Fx=D[F,xVar];Fy=D[F,yVar];Fz=D[F,zVar];
Amod=Mod[Fx/.Thread[vars->Pmod],p];
Bmod=Mod[Fy/.Thread[vars->Pmod],p];
Cmod=Mod[Fz/.Thread[vars->Pmod],p];
If[Amod==0&&Bmod==0&&Cmod==0,
Message[ECPCubicToWeierstrassCharTwoThree::singularPoint,Pmod,p];Return[$Failed]];
canonPt[pt_]:=Module[{xx,yy,zz},{xx,yy,zz}=Mod[pt,p];
Which[xx!=0,{1,Mod[yy*PowerMod[xx,-1,p],p],Mod[zz*PowerMod[xx,-1,p],p]},
yy!=0,{0,1,Mod[zz*PowerMod[yy,-1,p],p]},
True,{0,0,1}]];
onLineQ[pt_]:=Mod[Amod*pt[[1]]+Bmod*pt[[2]]+Cmod*pt[[3]],p]==0;
Pcanon=canonPt[Pmod];
candidates=Select[Tuples[Range[0,p-1],3],#=!={0,0,0}&];
Q=SelectFirst[candidates,(onLineQ[#]&&canonPt[#]!=Pcanon)&];
If[Q===Missing["NotFound"],Message[ECPCubicToWeierstrassCharTwoThree::noAuxPoint,p];Return[$Failed]];
R=SelectFirst[candidates,!onLineQ[#]&];
If[R===Missing["NotFound"],Message[ECPCubicToWeierstrassCharTwoThree::noAuxPoint,p];Return[$Failed]];
Mp={{Q[[1]],Pmod[[1]],R[[1]]},{Q[[2]],Pmod[[2]],R[[2]]},{Q[[3]],Pmod[[3]],R[[3]]}};
Xs=Symbol["X"];Ys=Symbol["Y"];Zs=Symbol["Z"];
newVarsOld=Mp . {Xs,Ys,Zs};
H=PolynomialMod[Expand[F/.Thread[vars->newVarsOld]],p];
badTerm=SelectFirst[{Xs^2*Ys,Xs*Ys^2,Ys^3},Mod[Coefficient[H,#],p]!=0&];
If[badTerm=!=Missing["NotFound"],
Message[ECPCubicToWeierstrassCharTwoThree::notFlex,Pmod,p];Return[$Failed]];
cYYZ=Mod[Coefficient[H,Ys^2*Zs],p];
cXXX=Mod[Coefficient[H,Xs^3],p];
k1=PowerMod[cYYZ,-1,p];
H=PolynomialMod[Expand[k1*H],p];
cXXX=Mod[k1*cXXX,p];
k2=Mod[(-1)*PowerMod[cXXX,-1,p],p];
H=PolynomialMod[Expand[H/.Xs->k2*Xs],p];
a1=Mod[Coefficient[H,Xs*Ys*Zs],p];
a3=Mod[Coefficient[H,Ys*Zs^2],p];
a2=Mod[-Coefficient[H,Xs^2*Zs],p];
a4=Mod[-Coefficient[H,Xs*Zs^2],p];
a6=Mod[-Coefficient[H,Zs^3],p];
(* FIX: the substitution X -> k2 X was not included in the returned matrix, so "Transformation"
   did not map the reported Weierstrass model to the original cubic whenever k2 != 1 *)
<|"WeierstrassCoefficients"->{a1,a2,a3,a4,a6},"Transformation"->Mod[Mp . DiagonalMatrix[{k2,1,1}],p],
"AuxiliaryPoints"-><|"Q"->Q,"P"->Pmod,"R"->R|>,"Characteristic"->p|>
];

(* 4B. LONG -> SHORT / NORMAL FORM OVER F_p *)

ecModP[x_,p_]:=Which[
  IntegerQ[x],Mod[x,p],
  Head[x]===Rational&&Mod[Denominator[x],p]!=0,Mod[Numerator[x]*PowerMod[Denominator[x],-1,p],p],
  True,$Failed];

ecFpModPoint[Infinity,_]:=Infinity;
ecFpModPoint[{x_,y_},p_]:=With[{xm=ecModP[x,p],ym=ecModP[y,p]},If[xm===$Failed||ym===$Failed,$Failed,{xm,ym}]];
ecFpModPoint[_,_]:=$Failed;

ecFpOnCurveQ[{x_,y_},{a1_,a2_,a3_,a4_,a6_},p_]:=Mod[y^2+a1*x*y+a3*y-(x^3+a2*x^2+a4*x+a6),p]==0;

ECPToShortWeierstrassFp[curve_,p_]:=Module[{c,cm,a1,a2,a3,a4,a6,b2,b4,b6,b8,disc,u=1,r,s,t,nf,case,nc,pure,inv,disc2,j},
  If[!(IntegerQ[p]&&PrimeQ[p]),ecMsg[ECPToShortWeierstrassFp,"notprime",p];Return[$Failed]];
  c=ecExtract[curve,ECPToShortWeierstrassFp];
  If[c===$Failed,Return[$Failed]];
  cm=ecModP[#,p]&/@c;
  If[MemberQ[cm,$Failed],Message[ECPToShortWeierstrassFp::badcoeff,Pick[c,cm,$Failed],p];Return[$Failed]];
  {a1,a2,a3,a4,a6}=cm;
  b2=Mod[a1^2+4*a2,p];b4=Mod[2*a4+a1*a3,p];b6=Mod[a3^2+4*a6,p];
  b8=Mod[a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2,p];
  disc=Mod[-b2^2*b8-8*b4^3-27*b6^2+9*b2*b4*b6,p];
  If[disc==0,ecMsg[ECPToShortWeierstrassFp,"singularp",cm,p];Return[$Failed]];
  If[p>3,
   r=Mod[-b2*PowerMod[12,-1,p],p];
   s=Mod[-a1*PowerMod[2,-1,p],p];
   t=Mod[-(a1*r+a3)*PowerMod[2,-1,p],p];
   case="p > 3: genuine short model y^2 = x^3 + A x + B (A = -c4/48, B = -c6/864 mod p)",
   nf=ECPNormalFormCharTwoThree[cm,p];
   If[nf===$Failed,Return[$Failed]];
   {u,r,s,t}=nf["Transformation"];
   case=nf["Case"]];
  nc=Mod[ECPTransformWeierstrass[cm,{u,r,s,t}],p];
  pure=(nc[[1]]==0&&nc[[2]]==0&&nc[[3]]==0);
  inv=ECPWInvariants[nc];
  disc2=Mod[inv["Discriminant"],p];
  j=Mod[PowerMod[Mod[inv["c4"],p],3,p]*PowerMod[disc2,-1,p],p];
  <|"Characteristic"->p,"OriginalCoefficients"->cm,"ShortCoefficients"->nc,
    "Transformation"->{u,r,s,t},"Case"->case,"PureShortQ"->pure,
    "ShortPair"->If[pure,{nc[[4]],nc[[5]]},Missing["NotAvailable"]],
    "Equation"->ECPFormattedEquation[nc],"Discriminant"->disc2,"jInvariant"->j|>];

ECPToShortCoordinatesFp[pt_,curve_,p_]:=Module[{res,Q,cm,u,r,s,t,x,y},
  res=ECPToShortWeierstrassFp[curve,p];
  If[res===$Failed,Return[$Failed]];
  If[!ecPointShapeQ[pt],ecMsg[ECPToShortCoordinatesFp,"badpoint",pt];Return[$Failed]];
  If[pt===Infinity,Return[Infinity]];
  Q=ecFpModPoint[pt,p];
  If[Q===$Failed,ecMsg[ECPToShortCoordinatesFp,"badcoord",pt,p];Return[$Failed]];
  cm=res["OriginalCoefficients"];
  If[!ecFpOnCurveQ[Q,cm,p],ecMsg[ECPToShortCoordinatesFp,"notOnCurveP",pt,cm,p];Return[$Failed]];
  {u,r,s,t}=res["Transformation"];
  {x,y}=Q;
  {Mod[(x-r)*PowerMod[u^2,-1,p],p],Mod[(y-s*(x-r)-t)*PowerMod[u^3,-1,p],p]}];

ECPFromShortCoordinatesFp[pt_,curve_,p_]:=Module[{res,Q,nc,u,r,s,t,X,Y},
  res=ECPToShortWeierstrassFp[curve,p];
  If[res===$Failed,Return[$Failed]];
  If[!ecPointShapeQ[pt],ecMsg[ECPFromShortCoordinatesFp,"badpoint",pt];Return[$Failed]];
  If[pt===Infinity,Return[Infinity]];
  Q=ecFpModPoint[pt,p];
  If[Q===$Failed,ecMsg[ECPFromShortCoordinatesFp,"badcoord",pt,p];Return[$Failed]];
  nc=res["ShortCoefficients"];
  If[!ecFpOnCurveQ[Q,nc,p],ecMsg[ECPFromShortCoordinatesFp,"notOnCurveP",pt,nc,p];Return[$Failed]];
  {u,r,s,t}=res["Transformation"];
  {X,Y}=Q;
  {Mod[u^2*X+r,p],Mod[u^3*Y+u^2*s*X+t,p]}];

(* 5. CURVE PARSERS *)

ecAffinePoly[{a1_,a2_,a3_,a4_,a6_}]:=With[{xs=Symbol["x"],ys=Symbol["y"]},
  Expand[ys^2+a1*xs*ys+a3*ys-(xs^3+a2*xs^2+a4*xs+a6)]];
ecAffinePoly[eq_Equal]:=Expand[eq[[1]]-eq[[2]]];
ecAffinePoly[poly_]/;!ListQ[poly]:=Expand[poly];

(* FIX: the public command now returns {polynomial, {xvar, yvar}} as documented, and accepts
   short pairs, Associations and Automatic (previously it returned only the polynomial and
   mis-handled Associations). Internal code uses ecAffinePoly. *)
ECPParseAffineCurve[input_]:=Module[{c,poly},
  poly=If[input===Automatic||AssociationQ[input]||MatchQ[input,{_,_}],
    c=ecExtract[input,ECPExtractCoefficients];
    If[c===$Failed,Return[$Failed]];
    ecAffinePoly[c],
    ecAffinePoly[input]];
  If[!MatchQ[poly,_ecAffinePoly]&&Variables[poly]=!={},{poly,detectXY[poly]},
   (Message[ECPExtractCoefficients::badcurve,input];$Failed)]];

homogenizeCubic[expr_,zs_]:=Module[{vs,rules,deg},
  vs=Variables[expr];
  rules=CoefficientRules[expr,vs];
  If[rules==={},Return[expr]];
  deg=Max[Total/@rules[[All,1]]];
  Expand[Total[(Times@@(vs^#[[1]]))*#[[2]]*zs^(deg-Total[#[[1]]])&/@rules]]];

ECPParseHomogeneousCurve[curve_]:=Module[{eq,expr,zs},
  zs=Symbol["z"];
  eq=If[curve===Automatic,
       If[AssociationQ[ECPack`$ECPCurrentEC]&&KeyExistsQ[ECPack`$ECPCurrentEC,"Coefficients"],
          ECPack`$ECPCurrentEC["Coefficients"],
          Message[ECPExtractCoefficients::unset];Return[$Failed]],
       curve];
  If[AssociationQ[eq]||(ListQ[eq]&&Length[eq]==2),
   eq=ecExtract[eq,ECPParseHomogeneousCurve];
   If[eq===$Failed,Return[$Failed]]];
  expr=Which[
    ListQ[eq]&&Length[eq]==5,ecAffinePoly[eq],
    Head[eq]===Equal,eq[[1]]-eq[[2]],
    True,eq];
  expr=Expand[expr];
  If[Length[Variables[expr]]==2,expr=homogenizeCubic[expr,zs]];
  Expand[expr]];

ECPExtractCoefficients[curve_]:=ecExtract[curve,ECPExtractCoefficients];

(* 6. PROJECTIVE HELPERS *)

zeroVecQ[v_List]:=AllTrue[v,TrueQ[Simplify[#]==0]&];

ECPAreProjectivelyEquivalent[P_,Q_]:=
 If[!(ListQ[P]&&ListQ[Q]&&Length[P]==3&&Length[Q]==3&&AllTrue[Join[P,Q],ecScalarQ]),
  (ecMsg[ECPAreProjectivelyEquivalent,"badarg","projective points","two lists of three scalars",{P,Q}];$Failed),
  If[zeroVecQ[P]||zeroVecQ[Q],False,
   TrueQ[Simplify[P[[1]]*Q[[2]]-P[[2]]*Q[[1]]==0]&&
         Simplify[P[[2]]*Q[[3]]-P[[3]]*Q[[2]]==0]&&
         Simplify[P[[1]]*Q[[3]]-P[[3]]*Q[[1]]==0]]]];

normalizeProjective[pt_List]:=Which[
  !TrueQ[Simplify[pt[[3]]]==0],Simplify[pt/pt[[3]]],
  !TrueQ[Simplify[pt[[1]]]==0],Simplify[pt/pt[[1]]],
  !TrueQ[Simplify[pt[[2]]]==0],Simplify[pt/pt[[2]]],
  True,pt];

tangentAuxPoint[{dx_,dy_,dz_},P_List]:=
  SelectFirst[{{-dy,dx,0},{-dz,0,dx},{0,-dz,dy},{0,dz,-dy}},
    (!zeroVecQ[#]&&!ECPAreProjectivelyEquivalent[#,P])&];

(* 7. CHORD AND TANGENT *)

ECPChordAndTangent[P_List,curve_:Automatic,vars_:Automatic]:=Module[
 {F,vs,sub,gx,gy,gz,Q,sPar,tPar,Ft,c30,c21,c12,c03,third},
 F=ECPParseHomogeneousCurve[curve];
 If[F===$Failed,Return[$Failed]];
 vs=If[vars===Automatic,ecOrderedVars[F],vars];
 If[Length[vs]=!=3,Message[ECPChordAndTangent::badVars,vs];Return[$Failed]];
 If[Length[P]=!=3||!AllTrue[P,ecScalarQ]||zeroVecQ[P],Message[ECPChordAndTangent::badPoint,P];Return[$Failed]];
 sub=Thread[vs->P];
 If[!TrueQ[Simplify[F/.sub]==0],Message[ECPChordAndTangent::notOnCurve,P,F];Return[$Failed]];
 {gx,gy,gz}=Simplify[D[F,#]/.sub]&/@vs;
 If[zeroVecQ[{gx,gy,gz}],Message[ECPChordAndTangent::singularPoint,P,F];Return[$Failed]];
 Q=tangentAuxPoint[{gx,gy,gz},P];
 If[Q===Missing["NotFound"],Message[ECPChordAndTangent::noAuxPoint,P];Return[$Failed]];
 Ft=Expand[F/.Thread[vs->(sPar*P+tPar*Q)]];
 c30=Simplify[Coefficient[Ft,sPar,3]];
 c21=Simplify[Coefficient[Coefficient[Ft,sPar,2],tPar,1]];
 c12=Simplify[Coefficient[Coefficient[Ft,sPar,1],tPar,2]];
 c03=Simplify[Coefficient[Ft,tPar,3]];

 If[!TrueQ[c30==0],Message[ECPChordAndTangent::notOnCurve,P,F];Return[$Failed]];
 If[!TrueQ[c21==0],Message[ECPChordAndTangent::noAuxPoint,P];Return[$Failed]];
 If[TrueQ[c12==0]&&TrueQ[c03==0],Message[ECPChordAndTangent::lineInCurve,P,F];Return[$Failed]];
 third=Simplify[c03*P-c12*Q];
 If[zeroVecQ[third],third=P];
 normalizeProjective[third]];

(* 8. CUBIC -> WEIERSTRASS *)

ECPPolynomialTransform[poly_,vars_,matrix_]:=Module[{newVars},
  If[!(ListQ[vars]&&vars=!={}&&PolynomialQ[poly,vars]),ecMsg[ECPPolynomialTransform,"badarg","polynomial and variable list","a polynomial in the given nonempty list of variables",{poly,vars}];Return[$Failed]];
  If[!(MatrixQ[matrix]&&Dimensions[matrix]=={Length[vars],Length[vars]}),ecMsg[ECPPolynomialTransform,"badarg","matrix",ToString[Length[vars]]<>"x"<>ToString[Length[vars]]<>" matrix",matrix];Return[$Failed]];
  newVars=Table[Sum[matrix[[i,j]]*vars[[j]],{j,1,Length[vars]}],{i,1,Length[vars]}];
  Expand[poly/.Thread[vars->newVars]]];

ECPPolynomialHomogeneous[poly_,vars_]:=Module[{terms,degrees},
  If[!(ListQ[vars]&&vars=!={}&&PolynomialQ[poly,vars]),ecMsg[ECPPolynomialHomogeneous,"badarg","polynomial and variable list","a polynomial in the given nonempty list of variables",{poly,vars}];Return[$Failed]];
  If[TrueQ[Expand[poly]==0],Return[True]];
  terms=MonomialList[poly,vars];
  If[Length[terms]==0,Return[True]];
  degrees=Total[Exponent[#,vars]]&/@terms;
  Max[degrees]===Min[degrees]];

ECPToWeierstrassForm[poly_,{xv_,yv_}]:=Module[{p,cf,cx3,cy2,q,cq,a1,a2,a3,a4,a6,stray},
  If[!PolynomialQ[poly,{xv,yv}],ecMsg[ECPToWeierstrassForm,"badarg","cubic","a polynomial in the two given variables",poly];Return[$Failed]];
  p=Expand[poly];
  cf[i_,j_]:=Coefficient[Coefficient[p,xv,i],yv,j];
  stray=Select[{{0,3},{1,2},{2,1},{1,3},{2,2},{2,3},{3,1},{3,2},{3,3},{4,0}},
               !TrueQ[Simplify[cf[#[[1]],#[[2]]]]==0]&];
  If[stray=!={},Message[ECPToWeierstrassForm::notWeierstrass,stray];Return[$Failed]];
  cx3=cf[3,0]; cy2=cf[0,2];
  If[TrueQ[Simplify[cy2]==0]||!TrueQ[Simplify[cx3+cy2]==0],
     Message[ECPToWeierstrassForm::badScale,cx3,cy2];Return[$Failed]];

  q=Expand[Simplify[p/cy2]];
  cq[i_,j_]:=Coefficient[Coefficient[q,xv,i],yv,j];
  a1=Simplify[cq[1,1]];
  a3=Simplify[cq[0,1]];
  a2=Simplify[-cq[2,0]];
  a4=Simplify[-cq[1,0]];
  a6=Simplify[-cq[0,0]];
  yv^2+a1*xv*yv+a3*yv-(xv^3+a2*xv^2+a4*xv+a6)];

Options[ECPCubicToWeierstrass]={"Algorithm"->"wolfram","Equivalence"->False,"Form"->"Long"};

ECPCubicToWeierstrass[P_,curve_:Automatic,opts:OptionsPattern[]]:=Block[
{F,algorithm,equivalence,form,vars,xVar,yVar,zVar,dxP2,dyP2,dzP2,Qaux,M,F2,a,F3,b,F5,F4,
 curveE,trans,invTrans,invM,P2,P3},
{algorithm,equivalence,form}=OptionValue[{"Algorithm","Equivalence","Form"}];
If[!MemberQ[{"Long","Short"},form],ecMsg[ECPCubicToWeierstrass,"badarg","option \"Form\"","\"Long\" or \"Short\"",form];Return[$Failed]];
If[!BooleanQ[equivalence],ecMsg[ECPCubicToWeierstrass,"badarg","option \"Equivalence\"","True or False",equivalence];Return[$Failed]];
If[algorithm=!="wolfram",Message[ECPCubicToWeierstrass::unsupportedAlgorithm,algorithm]];
F=ECPParseHomogeneousCurve[curve];
If[F===$Failed,Return[$Failed]];
vars=ecOrderedVars[F];
If[Length[vars]!=3,Message[ECPCubicToWeierstrass::notThreeVars,F];Return[$Failed]];
If[!ECPPolynomialHomogeneous[F,vars],Message[ECPCubicToWeierstrass::notHomogeneous,F];Return[$Failed]];
{xVar,yVar,zVar}=vars;
If[!ListQ[P]||Length[P]!=3||!AllTrue[P,ecScalarQ]||zeroVecQ[P],Message[ECPCubicToWeierstrass::notProjective,P];Return[$Failed]];
If[!TrueQ[Simplify[F/.Thread[vars->P]]==0],Message[ECPCubicToWeierstrass::notOnCurve,P,F];Return[$Failed]];
P2=ECPChordAndTangent[P,F,vars];
If[P2===$Failed,Return[$Failed]];
P3=ECPChordAndTangent[P2,F,vars];
If[P3===$Failed,Return[$Failed]];
If[ECPAreProjectivelyEquivalent[P2,P3],

 dxP2=Simplify[D[F,xVar]/.Thread[vars->P2]];
 dyP2=Simplify[D[F,yVar]/.Thread[vars->P2]];
 dzP2=Simplify[D[F,zVar]/.Thread[vars->P2]];

 If[zeroVecQ[{dxP2,dyP2,dzP2}],Message[ECPCubicToWeierstrass::singularPoint,P2,F];Return[$Failed]];
 If[zeroVecQ[P2],Message[ECPCubicToWeierstrass::zeroPoint];Return[$Failed]];
 Qaux=tangentAuxPoint[{dxP2,dyP2,dzP2},P2];
 If[Qaux===Missing["NotFound"],Message[ECPCubicToWeierstrass::singularPoint,P2,F];Return[$Failed]];
 M=Transpose[{Qaux,P2,{1,0,0}}];
 If[TrueQ[Simplify[Det[M]]==0],M=Transpose[{Qaux,P2,{0,1,0}}];
  If[TrueQ[Simplify[Det[M]]==0],M=Transpose[{Qaux,P2,{0,0,1}}];
   If[TrueQ[Simplify[Det[M]]==0],Message[ECPCubicToWeierstrass::singularMatrix];Return[$Failed]]]];
 F2=ECPPolynomialTransform[F,vars,M];
 a=Coefficient[F2,xVar^3];
 If[TrueQ[Simplify[a]==0],Message[ECPCubicToWeierstrass::zeroCubicCoeff];Return[$Failed]];
 F3=Expand[F2/a];
 b=Coefficient[F3,yVar^2*zVar];
 If[TrueQ[Simplify[b]==0],Message[ECPCubicToWeierstrass::zeroQuadraticCoeff];Return[$Failed]];
 F4=Expand[F3/.zVar->-1/b];
 curveE=ECPToWeierstrassForm[F4,{xVar,yVar}];
 If[curveE===$Failed,Return[$Failed]];
 If[form==="Short",curveE=ECPToShortWeierstrass[curveE]];
 If[equivalence,
  trans={xVar->M[[1,1]]*xVar+M[[1,2]]*yVar+M[[1,3]]*(-1/b),
         yVar->M[[2,1]]*xVar+M[[2,2]]*yVar+M[[2,3]]*(-1/b),
         zVar->M[[3,1]]*xVar+M[[3,2]]*yVar+M[[3,3]]*(-1/b)};
  Print["Transformation:"];
  Print[vars[[1]]," -> ",trans[[1,2]]];
  Print[vars[[2]]," -> ",trans[[2,2]]];
  Print[vars[[3]]," -> ",trans[[3,2]]];
  Print["Then multiply the equation with ",-1/a];
  invM=Inverse[M];
  invTrans={xVar->invM[[1,1]]*xVar+invM[[1,2]]*yVar+invM[[1,3]]*zVar,
            yVar->invM[[2,1]]*xVar+invM[[2,2]]*yVar+invM[[2,3]]*zVar,
            zVar->invM[[3,1]]*xVar+invM[[3,2]]*yVar+invM[[3,3]]*zVar};
  Print["Inverse transformation:"];
  Print["Homogenize the curve equation with respect to ",zVar,", then map"];
  Print[vars[[1]]," -> ",invTrans[[1,2]]];
  Print[vars[[2]]," -> ",invTrans[[2,2]]];
  Print[vars[[3]]," -> ",-b*invTrans[[3,2]]];
  Print["Then multiply the equation with ",-a];];
 curveE,

 M=Transpose[{P,P2,P3}];
 If[TrueQ[Simplify[Det[M]]==0],Message[ECPCubicToWeierstrass::linearDependence];Return[$Failed]];
 F2=ECPPolynomialTransform[F,vars,M];
 F3=Expand[Cancel[(F2/.{xVar->xVar^2,yVar->yVar*zVar,zVar->xVar*zVar})/(xVar^2*zVar)]];
 a=Coefficient[F3,xVar^3];
 If[TrueQ[Simplify[a]==0],Message[ECPCubicToWeierstrass::zeroCubicCoeff];Return[$Failed]];
 F4=Expand[F3/a];
 b=Coefficient[F4,yVar^2*zVar];
 If[TrueQ[Simplify[b]==0],Message[ECPCubicToWeierstrass::zeroQuadraticCoeff];Return[$Failed]];
 F5=Expand[F4/.zVar->-1/b];
 curveE=ECPToWeierstrassForm[F5,{xVar,yVar}];
 If[curveE===$Failed,Return[$Failed]];
 If[form==="Short",curveE=ECPToShortWeierstrass[curveE]];
 If[equivalence,
  trans={xVar->(M[[1,1]]*xVar*xVar+M[[1,2]]*yVar*(-1/b)+M[[1,3]]*xVar*(-1/b))*(-b),
         yVar->(M[[2,1]]*xVar*xVar+M[[2,2]]*yVar*(-1/b)+M[[2,3]]*xVar*(-1/b))*(-b),
         zVar->(M[[3,1]]*xVar*xVar+M[[3,2]]*yVar*(-1/b)+M[[3,3]]*xVar*(-1/b))*(-b)};
  Print["Transformation:"];
  Print[vars[[1]]," -> ",trans[[1,2]]];
  Print[vars[[2]]," -> ",trans[[2,2]]];
  Print[vars[[3]]," -> ",trans[[3,2]]];
  Print["Then multiply the equation with ",-1/(a*b^2*xVar^2)];
  invM=Inverse[M];
  invTrans={xVar->(invM[[1,1]]*xVar+invM[[1,2]]*yVar+invM[[1,3]]*zVar),
            yVar->(invM[[2,1]]*xVar+invM[[2,2]]*yVar+invM[[2,3]]*zVar),
            zVar->(invM[[3,1]]*xVar+invM[[3,2]]*yVar+invM[[3,3]]*zVar)};
  Print["Inverse transformation:"];
  Print["Homogenize the curve equation with respect to ",zVar,", then map"];
  Print[vars[[1]]," -> ",invTrans[[1,2]]*invTrans[[3,2]]];
  Print[vars[[2]]," -> ",invTrans[[1,2]]*invTrans[[2,2]]];
  Print[vars[[3]]," -> ",-b*invTrans[[3,2]]*invTrans[[3,2]]];];
 curveE]];

(* 8B. SHORT/LONG DUAL-INPUT SUPPORT *)

ToShortPoint[pt_,needsTransform_,origCurve_]:=
  If[TrueQ[needsTransform],ecToShortCore[pt,origCurve],pt];
FromShortPoint[pt_,needsTransform_,origCurve_]:=
  If[TrueQ[needsTransform],ecFromShortCore[pt,origCurve],pt];

(* 9. RATIONAL POINT ARITHMETIC *)

shortAddCore[Infinity,P_,_]:=P;
shortAddCore[P_,Infinity,_]:=P;
shortAddCore[{x1_,y1_},{x2_,y2_},{A_,B_}]:=Module[{m,x3,y3},
  If[TrueQ[x1==x2]&&(TrueQ[y1==-y2]||TrueQ[y1==0]),Return[Infinity]];
  m=If[TrueQ[x1==x2]&&TrueQ[y1==y2],(3*x1^2+A)/(2*y1),(y2-y1)/(x2-x1)];
  x3=m^2-x1-x2;
  y3=m*(x1-x3)-y1;
  {Simplify[x3],Simplify[y3]}];

ECPAdd[P1_,P2_,curve_]:=Module[{ab,needsT,origC,Q1,Q2,res},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPAdd];
  If[ab===$Failed,Return[$Failed]];
  Q1=ecPrepPoint[P1,ab,needsT,origC,ECPAdd];
  If[Q1===$Failed,Return[$Failed]];
  Q2=ecPrepPoint[P2,ab,needsT,origC,ECPAdd];
  If[Q2===$Failed,Return[$Failed]];
  If[P1===Infinity,Return[P2]];
  If[P2===Infinity,Return[P1]];
  res=shortAddCore[Q1,Q2,ab];
  If[TrueQ[needsT],ecFromShortCore[res,origC],res]];

shortMulCore[0,_,_]:=Infinity;
shortMulCore[_,Infinity,_]:=Infinity;
shortMulCore[n_Integer,P_,curve_]:=Module[{k=Abs[n],res=Infinity,base=P},
  If[n<0,base={P[[1]],-P[[2]]}];
  While[k>0,
   If[OddQ[k],res=shortAddCore[res,base,curve]];
   base=shortAddCore[base,base,curve];
   k=BitShiftRight[k,1];
   If[base===Infinity&&k>0,Break[]];];
  res];

ECPMultiply[n_,P_,curve_]:=Module[{ab,needsT,origC,Q,res},
  If[!IntegerQ[n],ecMsg[ECPMultiply,"badarg","scalar n","an integer",n];Return[$Failed]];
  {ab,needsT,origC}=ecResolveCurve[curve,ECPMultiply];
  If[ab===$Failed,Return[$Failed]];
  Q=ecPrepPoint[P,ab,needsT,origC,ECPMultiply];
  If[Q===$Failed,Return[$Failed]];
  res=shortMulCore[n,Q,ab];
  If[TrueQ[needsT],ecFromShortCore[res,origC],res]];

findPointOrderCore[point_,a_,b_,maxOrder_]:=Module[{currentPoint,order,res=Infinity},
  If[point===Infinity,Return[1]];
  currentPoint=point;
  order=1;
  While[order<=maxOrder,
   If[currentPoint===Infinity,res=order;Break[]];
   currentPoint=shortAddCore[currentPoint,point,{a,b}];
   order++;];
  res];

ECPOnCurveQ[pt_,curve_]:=Module[{ab,needsT,origC,Q},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPOnCurveQ];
  If[ab===$Failed,Return[False]];
  If[!ecPointShapeQ[pt],ecMsg[ECPOnCurveQ,"badpoint",pt];Return[False]];
  If[pt===Infinity,Return[True]];
  Q=If[TrueQ[needsT],ecToShortCore[pt,origC],pt];
  If[Q===$Failed,Return[False]];
  ecOnShortQ[Q,ab]];

(* 10. COORDINATE CHANGES *)

ECPFromShortCoordinates[Infinity,curve_:Automatic]:=If[ecLong[curve,ECPFromShortCoordinates]===$Failed,$Failed,Infinity];
ECPFromShortCoordinates[{X_,Y_},curve_:Automatic]:=Module[{c,sAB},
  If[!(ecScalarQ[X]&&ecScalarQ[Y]),ecMsg[ECPFromShortCoordinates,"badpoint",{X,Y}];Return[$Failed]];
  c=ecLong[curve,ECPFromShortCoordinates];
  If[c===$Failed,Return[$Failed]];
  sAB={Simplify[-c4Of[c]/48],Simplify[-c6Of[c]/864]};
  If[AllTrue[Join[{X,Y},sAB],ecExactQ]&&!ecOnShortQ[{X,Y},sAB],
   ecMsg[ECPFromShortCoordinates,"notOnCurve",{X,Y},Symbol["Y"]^2==Symbol["X"]^3+sAB[[1]]*Symbol["X"]+sAB[[2]]];Return[$Failed]];
  ecFromShortCore[{X,Y},c]];

ECPToLongCoordinates[Infinity,curve_,T_:{1,0,0,0}]:=If[ecLong[curve,ECPToLongCoordinates]===$Failed||!ecTransOK[T,ECPToLongCoordinates],$Failed,Infinity];
ECPToLongCoordinates[pt_,curve_]:=ECPToLongCoordinates[pt,curve,{1,0,0,0}];

(* FIX: previously this applied the INVERSE map (long -> transformed, x' = (x-r)/u^2) and tested
   membership on the long curve, contradicting its name and documentation. It now takes a point
   {x', y'} of the transformed model and returns x = u^2 x' + r, y = u^3 y' + u^2 s x' + t. *)
ECPToLongCoordinates[{x_,y_},curve_,T:{u_,r_,s_,t_}]:=Module[{c,ct},
  If[!(ecScalarQ[x]&&ecScalarQ[y]),ecMsg[ECPToLongCoordinates,"badpoint",{x,y}];Return[$Failed]];
  If[!ecTransOK[T,ECPToLongCoordinates],Return[$Failed]];
  c=ecLong[curve,ECPToLongCoordinates];
  If[c===$Failed,Return[$Failed]];
  ct=ECPTransformWeierstrass[c,T];
  If[ct===$Failed||!ecCheckOnLong[{x,y},ct,ECPToLongCoordinates],Return[$Failed]];
  {Simplify[u^2*x+r],Simplify[u^3*y+u^2*s*x+t]}];

(* 11. DISCRIMINANTS *)

ECPWeierstrassDiscriminant[curve_:Automatic]:=Module[{c,a1,a2,a3,a4,a6,b2,b4,b6,b8},
  c=ecExtract[curve,ECPWeierstrassDiscriminant];
  If[!MatchQ[c,{_,_,_,_,_}],Return[$Failed]];
  {a1,a2,a3,a4,a6}=c;
  b2=a1^2+4*a2;
  b4=2*a4+a1*a3;
  b6=a3^2+4*a6;
  b8=a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2;
  Simplify[-b2^2*b8-8*b4^3-27*b6^2+9*b2*b4*b6]];

ECPShortDiscriminant[{A_?NumericQ,B_?NumericQ}]:=Simplify[-16*(4*A^3+27*B^2)];

ECPShortDiscriminant[{A_,B_}]:=If[!(ecScalarQ[A]&&ecScalarQ[B]),(ecMsg[ECPShortDiscriminant,"badcurve",{A,B}];$Failed),Simplify[-16*(4*A^3+27*B^2)]];

ECPShortDiscriminant[A_,B_]/;ecScalarQ[A]&&ecScalarQ[B]:=ECPShortDiscriminant[{A,B}];

ECPShortDiscriminant[input_:Automatic]:=Module[{expr,xSym,ySym,A,B,short,c},
  If[AssociationQ[input]||(ListQ[input]&&Length[input]==5)||input===Automatic,
     short=ECPToShortWeierstrass[input];
     If[short===$Failed,Return[$Failed]];
     Return[ECPShortDiscriminant[short]]];
  c=ecExtract[input,ECPShortDiscriminant];
  If[c===$Failed,Return[$Failed]];
  If[!(TrueQ[c[[1]]==0]&&TrueQ[c[[2]]==0]&&TrueQ[c[[3]]==0]),
   short=ECPToShortWeierstrass[c];
   If[short===$Failed,Return[$Failed]];
   Return[ECPShortDiscriminant[short]]];
  expr=Expand[If[Head[input]===Equal,input[[1]]-input[[2]],input]];
  {xSym,ySym}=detectXY[expr];
  A=Coefficient[-Coefficient[expr,ySym,0],xSym,1];
  B=-((expr/.ySym->0)/.xSym->0);
  Simplify[-16*(4*A^3+27*B^2)]];

ECPJInvariant[curve:(_Association|_Equal|Automatic)]:=Module[{c=ecExtract[curve,ECPJInvariant]},If[c===$Failed,$Failed,ECPJInvariant[c]]];
ECPJInvariant[curve:(_Association|_Equal|Automatic),p_Integer?Positive]:=Module[{c=ecExtract[curve,ECPJInvariant]},If[c===$Failed,$Failed,ECPJInvariant[c,p]]];

ECPJInvariant[{A_,B_}]:=Module[{num,den},
If[!(ecScalarQ[A]&&ecScalarQ[B]),ecMsg[ECPJInvariant,"badcurve",{A,B}];Return[$Failed]];
num=6912*A^3;
den=4*A^3+27*B^2;
If[ecZeroQ[den]||TrueQ[Simplify[den]==0],Message[ECPJInvariant::singular,{A,B}];Return[$Failed],num/den]];

ECPJInvariant[{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2,b4,b6,b8,c4,delta},
If[!AllTrue[{a1,a2,a3,a4,a6},ecScalarQ],ecMsg[ECPJInvariant,"badcurve",{a1,a2,a3,a4,a6}];Return[$Failed]];
b2=a1^2+4*a2;
b4=2*a4+a1*a3;
b6=a3^2+4*a6;
b8=a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2;
c4=b2^2-24*b4;
delta=-b2^2*b8-8*b4^3-27*b6^2+9*b2*b4*b6;
If[ecZeroQ[delta]||TrueQ[Simplify[delta]==0],Message[ECPJInvariant::singular,{a1,a2,a3,a4,a6}];Return[$Failed],c4^3/delta]];

ECPJInvariant[{A_,B_},p_Integer?Positive]:=Module[{num,den,denInv},
If[!PrimeQ[p],Message[ECPJInvariant::notprime,p];Return[$Failed]];
If[!(IntegerQ[A]&&IntegerQ[B]),Message[ECPJInvariant::nonintegral,{A,B}];Return[$Failed]];
If[p==2,Message[ECPJInvariant::charTwoShort];Return[$Failed]];
num=Mod[6912*PowerMod[A,3,p],p];
den=Mod[4*PowerMod[A,3,p]+27*PowerMod[B,2,p],p];
If[den==0,Message[ECPJInvariant::singular,{A,B}];Return[$Failed],denInv=PowerMod[den,-1,p];
Mod[num*denInv,p]]];

ECPJInvariant[{a1_,a2_,a3_,a4_,a6_},p_Integer?Positive]:=Module[{b2,b4,b6,b8,c4,delta,deltaInv},
If[!PrimeQ[p],Message[ECPJInvariant::notprime,p];Return[$Failed]];
If[!AllTrue[{a1,a2,a3,a4,a6},IntegerQ],Message[ECPJInvariant::nonintegral,{a1,a2,a3,a4,a6}];Return[$Failed]];
b2=Mod[a1^2+4*a2,p];
b4=Mod[2*a4+a1*a3,p];
b6=Mod[a3^2+4*a6,p];
b8=Mod[a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2,p];
c4=Mod[b2^2-24*b4,p];
delta=Mod[-b2^2*b8-8*b4^3-27*b6^2+9*b2*b4*b6,p];
If[delta==0,Message[ECPJInvariant::singular,{a1,a2,a3,a4,a6}];Return[$Failed],deltaInv=PowerMod[delta,-1,p];
Mod[PowerMod[c4,3,p]*deltaInv,p]]];

(* 12. MINIMAL MODELS *)

primeFactorsOf[n_Integer]:=If[n==0,{},Select[FactorInteger[Abs[n]][[All,1]],PrimeQ]];

ECPMinimalQ[{A_,B_},p_Integer]:=Module[{vA,vB},
  If[!ecShortChecks[{A,B},ECPMinimalQ],Return[$Failed]];
  If[!IntegerQ[A]||!IntegerQ[B],Message[ECPMinimalQ::nonintegral,{A,B}];Return[False]];
  If[!PrimeQ[p]||p<=1,Message[ECPMinimalQ::notprime,p];Return[$Failed]];
  vA=If[A==0,Infinity,IntegerExponent[A,p]];
  vB=If[B==0,Infinity,IntegerExponent[B,p]];
  !(vA>=4&&vB>=6)];

ECPMinimalQ[{A_,B_}]:=Module[{pList},
  If[!ecShortChecks[{A,B},ECPMinimalQ],Return[$Failed]];
  If[!IntegerQ[A]||!IntegerQ[B],Message[ECPMinimalQ::nonintegral,{A,B}];Return[False]];
  pList=DeleteDuplicates[Join[primeFactorsOf[A],primeFactorsOf[B]]];
  AllTrue[pList,ECPMinimalQ[{A,B},#]&]];

ECPMinimalQ[curv_Association,args___]:=With[{l=ecAssocLong[curv]},If[l=!=None,ECPMinimalQ[l,args],ECPMinimalQ[curveAB[curv],args]]];

curveAB[curv_Association]:=Which[
  KeyExistsQ[curv,"A"]&&KeyExistsQ[curv,"B"],{curv["A"],curv["B"]},
  KeyExistsQ[curv,"MinimalCoefficients"]&&Length[curv["MinimalCoefficients"]]==2,curv["MinimalCoefficients"],
  True,{curv["A"],curv["B"]}];

ECPWInvariants[{a1_,a2_,a3_,a4_,a6_}/;AllTrue[{a1,a2,a3,a4,a6},ecScalarQ]]:=Module[{b2,b4,b6,b8,c4,c6,disc},
  b2=a1^2+4 a2;
  b4=2 a4+a1 a3;
  b6=a3^2+4 a6;
  b8=a1^2 a6+4 a2 a6-a1 a3 a4+a2 a3^2-a4^2;
  c4=b2^2-24 b4;
  c6=-b2^3+36 b2 b4-216 b6;
  disc=-b2^2 b8-8 b4^3-27 b6^2+9 b2 b4 b6;
  <|"b2"->b2,"b4"->b4,"b6"->b6,"b8"->b8,"c4"->c4,"c6"->c6,"Discriminant"->disc|>];

ECPTransformWeierstrass[{a1_,a2_,a3_,a4_,a6_},{u_,r_,s_,t_}]:=
 If[!AllTrue[{a1,a2,a3,a4,a6,u,r,s,t},ecScalarQ],(ecMsg[ECPTransformWeierstrass,"badarg","coefficients or transformation","scalars",{{a1,a2,a3,a4,a6},{u,r,s,t}}];$Failed),
 If[TrueQ[u==0],(Message[ECPTransformWeierstrass::zeroScale];$Failed),
  {(a1+2 s)/u,(a2-s a1+3 r-s^2)/u^2,(a3+r a1+2 t)/u^3,
   (a4-s a3+2 r a2-(t+r s) a1+3 r^2-2 s t)/u^4,
   (a6+r a4+r^2 a2+r^3-t a3-t^2-r t a1)/u^6}]];

ECPComposeTransformations[T1:{u1_,r1_,s1_,t1_},T2:{u2_,r2_,s2_,t2_}]:=
  If[!(ecTransOK[T1,ECPComposeTransformations]&&ecTransOK[T2,ECPComposeTransformations]),$Failed,
   {u1*u2,r1+u1^2*r2,s1+u1*s2,t1+u1^2*s1*r2+u1^3*t2}];

ECPToMinimalPoint[{x_,y_},T:{u_,r_,s_,t_}]:=Module[{},
  If[!(ecScalarQ[x]&&ecScalarQ[y]),ecMsg[ECPToMinimalPoint,"badpoint",{x,y}];Return[$Failed]];
  If[!ecTransOK[T,ECPToMinimalPoint],Return[$Failed]];
  {(x-r)/u^2,(y-s (x-r)-t)/u^3}];
ECPToMinimalPoint[Infinity,T_]:=If[ecTransOK[T,ECPToMinimalPoint],Infinity,$Failed];
ECPFromMinimalPoint[{X_,Y_},T:{u_,r_,s_,t_}]:=Module[{},
  If[!(ecScalarQ[X]&&ecScalarQ[Y]),ecMsg[ECPFromMinimalPoint,"badpoint",{X,Y}];Return[$Failed]];
  If[!ecTransOK[T,ECPFromMinimalPoint],Return[$Failed]];
  {u^2 X+r,u^3 Y+u^2 s X+t}];
ECPFromMinimalPoint[Infinity,T_]:=If[ecTransOK[T,ECPFromMinimalPoint],Infinity,$Failed];

ECPFormattedEquation[{a1_,a2_,a3_,a4_,a6_}/;AllTrue[{a1,a2,a3,a4,a6},ecScalarQ]]:=With[{xs=Symbol["x"],ys=Symbol["y"]},
  Module[{lhs,rhs},
   lhs=ys^2+If[TrueQ[a1!=0],a1 xs ys,0]+If[TrueQ[a3!=0],a3 ys,0];
   rhs=xs^3+If[TrueQ[a2!=0],a2 xs^2,0]+If[TrueQ[a4!=0],a4 xs,0]+If[TrueQ[a6!=0],a6,0];
   lhs==rhs]];

ECPFindLocalReduction[coeffs:{_,_,_,_,_},p_Integer]:=Module[{a1,a2,a3,a4,a6,disc,s,r,t,test},
  If[!(ListQ[coeffs]&&Length[coeffs]==5&&AllTrue[coeffs,IntegerQ]),ecMsg[ECPFindLocalReduction,"badarg","model","a list {a1,a2,a3,a4,a6} of five integers",coeffs];Return[$Failed]];
  If[!PrimeQ[p],ecMsg[ECPFindLocalReduction,"badarg","prime p","a prime number",p];Return[$Failed]];
  {a1,a2,a3,a4,a6}=coeffs;
  disc=ECPWInvariants[coeffs]["Discriminant"];
  If[disc==0,ecMsg[ECPFindLocalReduction,"isSingular",coeffs];Return[$Failed]];
  If[Mod[disc,p^12]!=0,Return[None]];
  If[p>3,
    s=Mod[-a1*PowerMod[2,-1,p],p];
    r=Mod[-(a2-s*a1-s^2)*PowerMod[3,-1,p^2],p^2];
    t=Mod[-(a3+r*a1)*PowerMod[2,-1,p^3],p^3];
    test=ECPTransformWeierstrass[coeffs,{p,r,s,t}];
    If[AllTrue[test,IntegerQ],{p,r,s,t},None],
    Catch[Do[Do[Do[With[{test2=ECPTransformWeierstrass[coeffs,{p,r,s,t}]},
       If[AllTrue[test2,IntegerQ],Throw[{p,r,s,t}]]],{t,0,p^3-1}],{r,0,p^2-1}],{s,0,p-1}];
     None]]];

normalizeWeierstrass[coeffs_List]:=Module[{c=coeffs,tot={1,0,0,0},sN,rN,tN,target},
  sN=(Mod[c[[1]],2]-c[[1]])/2;
  If[sN=!=0,c=ECPTransformWeierstrass[c,{1,0,sN,0}];tot=ECPComposeTransformations[tot,{1,0,sN,0}]];
  target=Mod[c[[2]]+1,3]-1;
  rN=(target-c[[2]])/3;
  If[rN=!=0,c=ECPTransformWeierstrass[c,{1,rN,0,0}];tot=ECPComposeTransformations[tot,{1,rN,0,0}]];
  tN=(Mod[c[[3]],2]-c[[3]])/2;
  If[tN=!=0,c=ECPTransformWeierstrass[c,{1,0,0,tN}];tot=ECPComposeTransformations[tot,{1,0,0,tN}]];
  {c,tot}];

ECPMinimalModel[coeffs_List,opts___]:=Module[
 {currentCoeffs,totalTransform,disc,primes,improved,step,p,normed},
 If[MatchQ[coeffs,{_,_}],Return[ECPMinimalModel[{0,0,0,coeffs[[1]],coeffs[[2]]},opts]]];
 If[Length[coeffs]=!=5,ecMsg[ECPMinimalModel,"badarg","coefficient list","a list {a1,a2,a3,a4,a6} of 5 rational numbers",coeffs];Return[$Failed]];
 If[!AllTrue[coeffs,MatchQ[#,_Integer|_Rational]&],Message[ECPMinimalModel::nonrational,coeffs];Return[$Failed]];
 currentCoeffs=coeffs;
 totalTransform={1,0,0,0};
 If[!AllTrue[currentCoeffs,IntegerQ],
  With[{u=LCM@@(Denominator/@currentCoeffs)},
   currentCoeffs=ECPTransformWeierstrass[currentCoeffs,{1/u,0,0,0}];
   totalTransform={1/u,0,0,0};]];
 If[!AllTrue[currentCoeffs,IntegerQ],
  Message[ECPMinimalModel::singularCurve,coeffs];Return[$Failed]];
 disc=ECPWInvariants[currentCoeffs]["Discriminant"];
 If[disc==0,Message[ECPMinimalModel::singularCurve,coeffs];Return[$Failed]];
 improved=True;
 While[improved,improved=False;
  primes=primeFactorsOf[disc];
  Do[step=ECPFindLocalReduction[currentCoeffs,p];
   If[step=!=None,
    currentCoeffs=ECPTransformWeierstrass[currentCoeffs,step];
    totalTransform=ECPComposeTransformations[totalTransform,step];
    disc=ECPWInvariants[currentCoeffs]["Discriminant"];
    improved=True;
    Break[];],{p,primes}];];
 normed=normalizeWeierstrass[currentCoeffs];
 currentCoeffs=normed[[1]];
 totalTransform=ECPComposeTransformations[totalTransform,normed[[2]]];
 <|"MinimalCoefficients"->currentCoeffs,
   "Equation"->ECPFormattedEquation[currentCoeffs],
   "Transformation"->totalTransform,
   "Discriminant"->ECPWInvariants[currentCoeffs]["Discriminant"],
   "OldDiscriminant"->ECPWInvariants[coeffs]["Discriminant"],
   "IsMinimal"->True|>];

ECPMinimalModelShort[{A_,B_},opts___]:=Module[
 {origDisc,currentA,currentB,u=1,primes,reduced=True,xs,ys},
 xs=Symbol["x"]; ys=Symbol["y"];
 If[!ecShortChecks[{A,B},ECPMinimalModelShort],Return[$Failed]];
 origDisc=-16 (4 A^3+27 B^2);
 If[origDisc==0,Message[ECPMinimalModelShort::singularCurve,{A,B}];Return[$Failed]];
 If[!IntegerQ[A]||!IntegerQ[B],Message[ECPMinimalModelShort::nonintegral,{A,B}];Return[
   <|"MinimalCoefficients"->{A,B},"Equation"->(ys^2==xs^3+A xs+B),
     "TransformationScale"->1,"Discriminant"->origDisc,"OldDiscriminant"->origDisc,
     "IsMinimal"->False|>]];
 currentA=A;currentB=B;
 While[reduced,reduced=False;
  primes=primeFactorsOf[-16 (4 currentA^3+27 currentB^2)];
  Do[If[Mod[currentA,p^4]==0&&Mod[currentB,p^6]==0,
    currentA/=p^4;currentB/=p^6;u*=p;reduced=True;Break[];],{p,primes}];];
 <|"MinimalCoefficients"->{currentA,currentB},
   "Equation"->(ys^2==xs^3+currentA xs+currentB),
   "TransformationScale"->u,
   "Discriminant"->-16 (4 currentA^3+27 currentB^2),
   "OldDiscriminant"->origDisc,
   "IsMinimal"->True|>];

ECPIsMinimal[coeffs:{_,_,_,_,_}]:=Module[{disc,primes},
  If[!AllTrue[coeffs,IntegerQ],Message[ECPIsMinimal::nonintegral,coeffs];Return[False]];
  disc=ECPWInvariants[coeffs]["Discriminant"];
  If[disc==0,Message[ECPIsMinimal::singularCurve,coeffs];Return[False]];
  primes=primeFactorsOf[disc];
  AllTrue[primes,ECPFindLocalReduction[coeffs,#]===None&]];

ECPIsMinimalShort[{A_,B_}]:=ECPMinimalQ[{A,B}];
ECPIsMinimalShort[curv_Association]:=ECPMinimalQ[curv];
ECPIsMinimalShort[curve:Except[{_,_}|_Association]]:=ECPMinimalQ[curve];

(* 13. RATIONAL POINT SEARCH, TORSION, HEIGHTS, GENERATORS *)

ECPSearchPoints[{A_,B_},bound_:50]:=Module[{pts={},rhs,yv,maxDen=10,ratSquareQ},
  If[!(IntegerQ[bound]&&bound>0),ecMsg[ECPSearchPoints,"badarg","search bound","a positive integer",bound];Return[$Failed]];
  If[!ecShortChecks[{A,B},ECPSearchPoints],Return[$Failed]];
  If[!(MatchQ[A,_Integer|_Rational]&&MatchQ[B,_Integer|_Rational]),Message[ECPSearchPoints::nonrational,{A,B}];Return[$Failed]];
  ratSquareQ[r_]:=IntegerQ[Sqrt[Numerator[r]]]&&IntegerQ[Sqrt[Denominator[r]]];
  Do[Do[If[GCD[pp,qq]==1,
     rhs=(pp/qq)^3+A*(pp/qq)+B;
     If[rhs>=0&&ratSquareQ[rhs],
      yv=Sqrt[rhs];
      AppendTo[pts,{pp/qq,yv}];
      If[yv!=0,AppendTo[pts,{pp/qq,-yv}]];]],{pp,-bound,bound}],{qq,1,maxDen}];
  DeleteDuplicates[pts]];

ECPSearchPoints[curve:Except[{_,_}],bound_:50]:=Module[{c,pts={},maxDen=10,ratSquareQ,x,L,dd,s},
  If[!(IntegerQ[bound]&&bound>0),ecMsg[ECPSearchPoints,"badarg","search bound","a positive integer",bound];Return[$Failed]];
  c=ecLong[curve,ECPSearchPoints];
  If[c===$Failed,Return[$Failed]];
  If[!AllTrue[c,MatchQ[#,_Integer|_Rational]&],Message[ECPSearchPoints::nonrational,c];Return[$Failed]];
  ratSquareQ[r_]:=IntegerQ[Sqrt[Numerator[r]]]&&IntegerQ[Sqrt[Denominator[r]]];
  Do[Do[If[GCD[pp,qq]==1,
     x=pp/qq;
     L=c[[1]]*x+c[[3]];
     dd=L^2+4*(x^3+c[[2]]*x^2+c[[4]]*x+c[[5]]);
     If[dd>=0&&ratSquareQ[dd],
      s=Sqrt[dd];
      AppendTo[pts,{x,(-L+s)/2}];
      If[s!=0,AppendTo[pts,{x,(-L-s)/2}]]]],{pp,-bound,bound}],{qq,1,maxDen}];
  DeleteDuplicates[pts]];

integerCubicRoots[A_Integer,c_Integer]:=If[c==0,
  DeleteDuplicates[Join[{0},Select[{Sqrt[-A],-Sqrt[-A]},IntegerQ]]],
  Select[Join[#,-#]&[Divisors[Abs[c]]],#^3+A*#+c==0&]];

$ECPNagellLutzDiscLimit=10^60;

torsionBySearch[curve_,bound_]:=
  Prepend[Select[ECPSearchPoints[curve,bound],ECPFindPointOrder[#,curve]=!=Infinity&],Infinity];

ECPFindTorsionPoints[curve:{A_,B_}]:=Module[{disc,sqDivs,cands,pts},
  If[!(ecScalarQ[A]&&ecScalarQ[B]),ecMsg[ECPFindTorsionPoints,"badcurve",curve];Return[$Failed]];
  disc=-16*(4*A^3+27*B^2);
  If[TrueQ[disc==0],Message[ECPFindTorsionPoints::singular,A,B];Return[$Failed]];
  If[!(IntegerQ[A]&&IntegerQ[B]),
    If[MatchQ[A,_Integer|_Rational]&&MatchQ[B,_Integer|_Rational],Return[torsionRescaled[A,B]]];
    Message[ECPFindTorsionPoints::nonintegral,{A,B},50];
    Return[torsionBySearch[curve,50]]];
  If[Abs[disc]>$ECPNagellLutzDiscLimit,
    Message[ECPFindTorsionPoints::bigdisc,Abs[disc],$ECPNagellLutzDiscLimit];
    Return[torsionBySearch[curve,50]]];
  sqDivs=Sqrt/@Select[Divisors[Abs[disc]],IntegerQ[Sqrt[#]]&];
  cands=Join[
    {#,0}&/@integerCubicRoots[A,B],
    Flatten[Table[({{#,yv},{#,-yv}}&/@integerCubicRoots[A,B-yv^2]),{yv,sqDivs}],2]];
  pts=DeleteDuplicates[Select[cands,(ECPOnCurveQ[#,curve]&&ECPFindPointOrder[#,curve]=!=Infinity)&]];
  Prepend[SortBy[pts,{#[[1]],#[[2]]}&],Infinity]];

ECPFindTorsionPoints[curve:Except[{_,_}]]:=Module[{ab,needsT,origC,pts},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPFindTorsionPoints];
  If[ab===$Failed,Return[$Failed]];
  pts=ECPFindTorsionPoints[ab];
  If[pts===$Failed,Return[$Failed]];
  If[needsT,FromShortPoint[#,needsT,origC]&/@pts,pts]];

ECPTorsionSubgroup[curve:{A_,B_}]:=Module[{pts,n,orders,p2,maxPt,gens,struct},
  pts=ECPFindTorsionPoints[curve];
  If[pts===$Failed,Return[$Failed]];
  n=Length[pts];
  orders=Map[ECPFindPointOrder[#,curve]&,pts];
  If[Count[orders,2]==3,
   p2=Select[pts,ECPFindPointOrder[#,curve]==2&];
   maxPt=First@SortBy[pts,-ECPFindPointOrder[#,curve]&];
   (* FIX: the second generator must be a 2-torsion point OUTSIDE <maxPt>; previously the first
      2-torsion point other than maxPt was taken, which can be (ord/2)*maxPt for Z/2 x Z/4, Z/2 x Z/6, Z/2 x Z/8 *)
   With[{half=ECPMultiply[ECPFindPointOrder[maxPt,curve]/2,maxPt,curve]},
    gens=DeleteDuplicates[{First@Select[p2,#=!=maxPt&&#=!=half&],maxPt}]];
   struct=StringTemplate["Z/2Z x Z/``Z"][n/2],
   gens=Select[pts,ECPFindPointOrder[#,curve]==n&,1];
   struct=StringTemplate["Z/``Z"][n]];

  If[gens==={},Message[ECPTorsionSubgroup::badGroup,n]];
  <|"Order"->n,"Structure"->struct,"Generators"->gens,"Points"->pts|>];

ECPTorsionSubgroup[curve:Except[{_,_}]]:=Module[{ab,needsT,origC,res},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPTorsionSubgroup];
  If[ab===$Failed,Return[$Failed]];
  res=ECPTorsionSubgroup[ab];
  If[res===$Failed,Return[$Failed]];
  If[needsT,
    res=Association[res,
      "Points"->(FromShortPoint[#,needsT,origC]&/@res["Points"]),
      "Generators"->(FromShortPoint[#,needsT,origC]&/@res["Generators"])]];
  res];

ECPNaiveHeight[Infinity]:=0;
ECPNaiveHeight[{x_,y_}]:=If[!(MatchQ[x,_Integer|_Rational]&&ecScalarQ[y]),
  (ecMsg[ECPNaiveHeight,"badarg","point","a pair {x,y} with rational x",{x,y}];$Failed),
  N[Log[Max[Abs[Numerator[x]],Abs[Denominator[x]],1]]]];

ECPCanonicalHeight[Infinity,curve_,___]:=If[First[ecResolveCurve[curve,ECPCanonicalHeight]]===$Failed,$Failed,0];

canonHeightCore[Q0_,ab_,maxIter_]:=Module[{q=Q0,h,hPrev=0.,tors=False,i},
  If[q===Infinity,Return[0.]];
  (* h(Q) = lim h_naive(2^i Q)/4^i ; the naive height is taken on the short model and halved at the end *)
  h=N[ECPNaiveHeight[q],20];
  Do[hPrev=h;
   q=shortMulCore[2,q,ab];
   If[q===Infinity,tors=True;Break[]];
   h=N[ECPNaiveHeight[q],20]/4^i;
   (* stop only when successive terms agree to ~1e-8 and the value is clearly positive *)
   If[i>=4&&h>10^-6&&Abs[h-hPrev]<10^-8,Break[]],
   {i,1,maxIter}];
  If[tors,0.,N[h/2,8]]];

ECPCanonicalHeight[P_,curve_,maxIter_:8]:=Module[{ab,needsT,origC,Q},
  If[!(IntegerQ[maxIter]&&maxIter>0),ecMsg[ECPCanonicalHeight,"badarg","maxIter","a positive integer",maxIter];Return[$Failed]];
  {ab,needsT,origC}=ecResolveCurve[curve,ECPCanonicalHeight];
  If[ab===$Failed,Return[$Failed]];
  Q=ecPrepPoint[P,ab,needsT,origC,ECPCanonicalHeight];
  If[Q===$Failed,Return[$Failed]];
  canonHeightCore[Q,ab,maxIter]];

heightPairingCore[Q1_,Q2_,ab_]:=If[Q1===Infinity||Q2===Infinity,0.,
  N[(canonHeightCore[shortAddCore[Q1,Q2,ab],ab,8]-canonHeightCore[Q1,ab,8]-canonHeightCore[Q2,ab,8])/2,8]];

ECPHeightPairing[P1_,P2_,curve_]:=Module[{ab,needsT,origC,Q1,Q2},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPHeightPairing];
  If[ab===$Failed,Return[$Failed]];
  Q1=ecPrepPoint[P1,ab,needsT,origC,ECPHeightPairing];
  If[Q1===$Failed,Return[$Failed]];
  Q2=ecPrepPoint[P2,ab,needsT,origC,ECPHeightPairing];
  If[Q2===$Failed,Return[$Failed]];
  heightPairingCore[Q1,Q2,ab]];

ECPHeightMatrix[points_List,curve_]:=Module[{ab,needsT,origC,shortPts},
  {ab,needsT,origC}=ecResolveCurve[curve,ECPHeightMatrix];
  If[ab===$Failed,Return[$Failed]];
  shortPts=ecPrepPoint[#,ab,needsT,origC,ECPHeightMatrix]&/@points;
  If[MemberQ[shortPts,$Failed],Return[$Failed]];
  Table[heightPairingCore[shortPts[[i]],shortPts[[j]],ab],{i,Length[shortPts]},{j,Length[shortPts]}]];

ECPIndependentQ[{},curve_,tol_:0.01]:=If[!ecTolOK[tol,ECPIndependentQ]||First[ecResolveCurve[curve,ECPIndependentQ]]===$Failed,$Failed,True];
ECPIndependentQ[{P_},curve_,tol_:0.01]:=Module[{h},
  If[!ecTolOK[tol,ECPIndependentQ],Return[$Failed]];
  h=ECPCanonicalHeight[P,curve];
  If[h===$Failed,$Failed,h>tol]];
ECPIndependentQ[points_List,curve_,tol_:0.01]:=Module[{mat,det},
  If[!ecTolOK[tol,ECPIndependentQ],Return[$Failed]];
  mat=ECPHeightMatrix[points,curve];
  If[mat===$Failed,Return[$Failed]];
  If[!MatrixQ[mat,NumericQ],Return[False]];
  det=Det[mat];
  Abs[N[det,8]]>tol];

ECPRankUpperBound[{A_,B_}]:=Module[{delta},
  If[!ecShortChecks[{A,B},ECPRankUpperBound],Return[$Failed]];
  If[!(IntegerQ[A]&&IntegerQ[B]),Message[ECPRankUpperBound::nonintegral,{A,B}];Return[$Failed]];
  delta=-16 (4 A^3+27 B^2);
  If[delta==0,0,Min[Length[primeFactorsOf[delta]],4]]];

ECPFindGenerators[{A_,B_},opts:OptionsPattern[{"SearchBound"->50,"Verbose"->False}]]:=Module[
 {bound,verbose,curve={A,B},torsion,rankBound,allPoints,candidates,generators={},
  rank,heightMat,det,startTime,endTime},
 startTime=AbsoluteTime[];
 If[!ecShortChecks[{A,B},ECPFindGenerators],Return[$Failed]];
 If[!(IntegerQ[A]&&IntegerQ[B]),ecMsg[ECPFindGenerators,"badarg","{A,B}","two integers (for rational coefficients pass the curve as {0,0,0,A,B})",{A,B}];Return[$Failed]];
 If[!ecGenOptsOK[{opts},OptionValue["SearchBound"],OptionValue["Verbose"]],Return[$Failed]];
 bound=OptionValue["SearchBound"];
 verbose=OptionValue["Verbose"];
 If[verbose,Print["=== Elliptic Curve: y^2 = x^3 + (",A,")x + (",B,") ==="]];
 torsion=ECPFindTorsionPoints[curve];
 If[torsion===$Failed,Return[$Failed]];
 rankBound=ECPRankUpperBound[curve];
 If[rankBound===$Failed,Return[$Failed]];
 If[verbose,Print["Found ",Length[torsion]," torsion points."];
  Print["Upper bound on rank: ",rankBound];];
 allPoints=ECPSearchPoints[curve,bound];
 candidates=Select[allPoints,!MemberQ[torsion,#]&&ECPCanonicalHeight[#,curve]>0.01&];
 (* FIX: the search used to stop once Length[generators] reached ECPRankUpperBound, which is only a heuristic
    (389a1 has rank 2 but one bad prime, so it was reported as rank 1). All candidates are now tested. *)
 Do[If[ECPIndependentQ[Append[generators,pt],curve],AppendTo[generators,pt];],{pt,SortBy[candidates,ECPNaiveHeight]}];
 rank=Length[generators];
 endTime=AbsoluteTime[];
 heightMat=If[rank>0,ECPHeightMatrix[generators,curve],{}];
 det=If[rank>0,Det[heightMat],0];
 <|"Rank"->rank,"Generators"->generators,"Torsion"->torsion,"RankBound"->rankBound,
   "Curve"->curve,"HeightMatrix"->heightMat,"Determinant"->det,"Time"->(endTime-startTime)|>];

(* 14. FINITE FIELD ARITHMETIC AND ELGAMAL *)

(* 15./16. Point counting, membership and order over F_p: see section 17. *)

ECPAddFp[P1_,P2_,curve_,p_]:=ellipticAddFpLong[P1,P2,curve,p];

ECPMultiplyFp[n_,point_,curve_,p_]:=ellipticMultiplyFpLong[n,point,curve,p];

(* 17. LONG-FORM GENERALISATIONS *)

ecLong[curve_,f_]:=Module[{c},
  c=ecExtract[curve,f];
  If[c===$Failed,Return[$Failed]];
  If[AllTrue[c,ecExactQ]&&ecZeroQ[ecDisc[c]],ecMsg[f,"isSingular",c];Return[$Failed]];
  c];

ECPWInvariants[curve:Except[{_,_,_,_,_}]]:=Module[{c=ecExtract[curve,ECPWInvariants]},
  If[c===$Failed,$Failed,ECPWInvariants[c]]];

ECPFormattedEquation[curve:Except[{_,_,_,_,_}]]:=Module[{c=ecExtract[curve,ECPFormattedEquation]},
  If[c===$Failed,$Failed,ECPFormattedEquation[c]]];

ECPTransformWeierstrass[curve:Except[{_,_,_,_,_}],t:{_,_,_,_}]:=Module[{c=ecExtract[curve,ECPTransformWeierstrass]},
  If[c===$Failed,$Failed,ECPTransformWeierstrass[c,t]]];

ECPFindLocalReduction[curve:Except[{_,_,_,_,_}],p_Integer]:=Module[{c=ecLong[curve,ECPFindLocalReduction]},
  If[c===$Failed,$Failed,ECPFindLocalReduction[c,p]]];

ECPIsMinimal[curve:Except[{_,_,_,_,_}]]:=Module[{c=ecLong[curve,ECPIsMinimal]},
  If[c===$Failed,$Failed,ECPIsMinimal[c]]];

ECPNormalFormCharTwoThree[curve:Except[{_,_,_,_,_}],p_Integer]:=Module[{c=ecExtract[curve,ECPNormalFormCharTwoThree]},
  If[c===$Failed,$Failed,ECPNormalFormCharTwoThree[c,p]]];

ECPMinimalQ[c:{_,_,_,_,_},p_Integer]:=Module[{cc=ecLong[c,ECPMinimalQ]},
  If[cc===$Failed,Return[$Failed]];
  If[!AllTrue[cc,IntegerQ],Message[ECPMinimalQ::nonintegral,cc];Return[False]];
  If[!PrimeQ[p],Message[ECPMinimalQ::notprime,p];Return[$Failed]];
  ECPFindLocalReduction[cc,p]===None];
ECPMinimalQ[c:{_,_,_,_,_}]:=Module[{cc=ecLong[c,ECPMinimalQ]},
  If[cc===$Failed,Return[$Failed]];
  If[!AllTrue[cc,IntegerQ],Message[ECPMinimalQ::nonintegral,cc];Return[False]];
  ECPIsMinimal[cc]];
ECPMinimalQ[curve:(_Equal|Automatic),args___]:=Module[{c=ecExtract[curve,ECPMinimalQ]},
  If[c===$Failed,$Failed,ECPMinimalQ[c,args]]];
ECPMinimalQ[curve:Except[_List|_Association|_Integer|_Equal|Automatic],args___]:=Module[{c=ecExtract[curve,ECPMinimalQ]},
  If[c===$Failed,$Failed,ECPMinimalQ[c,args]]];

ecAssocLong[curv_Association]:=Which[
  KeyExistsQ[curv,"Coefficients"]&&MatchQ[curv["Coefficients"],{_,_,_,_,_}],curv["Coefficients"],
  KeyExistsQ[curv,"MinimalCoefficients"]&&MatchQ[curv["MinimalCoefficients"],{_,_,_,_,_}],curv["MinimalCoefficients"],
  True,None];

ECPMinimalModelShort[curve:Except[{_,_}],opts___]:=Module[{c=ecLong[curve,ECPMinimalModelShort]},
  If[c===$Failed,Return[$Failed]];
  If[c[[1]]===0&&c[[2]]===0&&c[[3]]===0,ECPMinimalModelShort[{c[[4]],c[[5]]},opts],ECPMinimalModel[c,opts]]];

ECPMinimalModel[curve:Except[_List],opts___]:=Module[{c=ecLong[curve,ECPMinimalModel]},
  If[c===$Failed,$Failed,ECPMinimalModel[c,opts]]];

ECPRankUpperBound[curve:Except[{_,_}]]:=Module[{c,delta},
  c=ecLong[curve,ECPRankUpperBound];
  If[c===$Failed,Return[$Failed]];
  If[!AllTrue[c,IntegerQ],Message[ECPRankUpperBound::nonintegral,c];Return[$Failed]];
  delta=ecDisc[c];
  Min[Length[primeFactorsOf[delta]],4]];

    ecIntegralScale[{A_,B_}]:=If[MatchQ[A,_Integer|_Rational]&&MatchQ[B,_Integer|_Rational],
  Times@@(#^Max[Ceiling[IntegerExponent[Denominator[A],#]/4],Ceiling[IntegerExponent[Denominator[B],#]/6]]&/@
    Select[Union[First/@FactorInteger[Denominator[A]],First/@FactorInteger[Denominator[B]]], # > 1 &]),1];

ECPFindGenerators[curve:Except[{_,_}],opts:OptionsPattern[{"SearchBound"->50,"Verbose"->False}]]:=
 Module[{ab,needsT,origC,u,abI,res,mapBack,gens,tors},
  If[!ecGenOptsOK[{opts},OptionValue["SearchBound"],OptionValue["Verbose"]],Return[$Failed]];
  {ab,needsT,origC}=ecResolveCurve[curve,ECPFindGenerators];
  If[ab===$Failed,Return[$Failed]];
  u=ecIntegralScale[ab];
  abI={u^4*ab[[1]],u^6*ab[[2]]};
  If[OptionValue["Verbose"],
   Print["(curve given in non-short form: working on its integral short model; points are mapped back to your coordinates)"]];
  res=ECPFindGenerators[abI,opts];
  If[res===$Failed,Return[$Failed]];
  mapBack[P_]:=If[P===Infinity,Infinity,FromShortPoint[{P[[1]]/u^2,P[[2]]/u^3},needsT,origC]];
  gens=mapBack/@res["Generators"];
  tors=mapBack/@res["Torsion"];
  Association[res,"Generators"->gens,"Torsion"->tors,"Curve"->curve,
   "HeightMatrix"->If[Length[gens]>0,ECPHeightMatrix[gens,curve],{}]]];

torsionRescaled[A_,B_]:=Module[{u=ecIntegralScale[{A,B}],pts},
  pts=ECPFindTorsionPoints[{u^4*A,u^6*B}];
  If[pts===$Failed,Return[$Failed]];
  If[#===Infinity,Infinity,{#[[1]]/u^2,#[[2]]/u^3}]&/@pts];

findPointOrderCurve[pt_,curve_,mo_]:=Module[{ab,needsT,origC,Q},
  If[!(IntegerQ[mo]&&mo>0),ecMsg[ECPFindPointOrder,"badarg","maxOrder","a positive integer",mo];Return[$Failed]];
  {ab,needsT,origC}=ecResolveCurve[curve,ECPFindPointOrder];
  If[ab===$Failed,Return[$Failed]];
  Q=ecPrepPoint[pt,ab,needsT,origC,ECPFindPointOrder];
  If[Q===$Failed,Return[$Failed]];
  findPointOrderCore[Q,ab[[1]],ab[[2]],mo]];

ECPFindPointOrder[point_,curve_,maxOrder_:12]:=findPointOrderCurve[point,curve,maxOrder];
(* FIX: documented forms ECPFindPointOrder[point, a, b] and ECPPointOrder[point, curve] *)
ECPFindPointOrder[point_,a:(_Integer|_Rational),b:(_Integer|_Rational)]:=findPointOrderCurve[point,{a,b},12];
ECPPointOrder[point_,curve_]:=findPointOrderCurve[point,curve,12];

fpNegL[Infinity,_,_]:=Infinity;
fpNegL[{x_,y_},{a1_,a2_,a3_,a4_,a6_},p_]:={x,Mod[-y-a1*x-a3,p]};

fpAddL[Infinity,Q_,_,_]:=Q;
fpAddL[P_,Infinity,_,_]:=P;
fpAddL[{x1_,y1_},{x2_,y2_},{a1_,a2_,a3_,a4_,a6_},p_]:=Module[{lam,x3,y3,nu},
  If[Mod[x1-x2,p]==0,
   If[Mod[y1+y2+a1*x2+a3,p]==0,
    Infinity,
    lam=Mod[(3*x1^2+2*a2*x1+a4-a1*y1)*PowerMod[2*y1+a1*x1+a3,-1,p],p];
    nu=Mod[y1-lam*x1,p];
    x3=Mod[lam^2+a1*lam-a2-x1-x2,p];
    y3=Mod[-(lam+a1)*x3-nu-a3,p];
    {x3,y3}],
   lam=Mod[(y2-y1)*PowerMod[x2-x1,-1,p],p];
   nu=Mod[y1-lam*x1,p];
   x3=Mod[lam^2+a1*lam-a2-x1-x2,p];
   y3=Mod[-(lam+a1)*x3-nu-a3,p];
   {x3,y3}]];

fpMulL[n_,P_,c_,p_]:=Module[{k,res=Infinity,base},
  If[n==0||P===Infinity,Return[Infinity]];
  k=Abs[n];
  base=If[n<0,fpNegL[P,c,p],P];
  While[k>0,
   If[OddQ[k],res=fpAddL[res,base,c,p]];
   base=fpAddL[base,base,c,p];
   k=Floor[k/2]];
  res];

ecFpLongCurve[curve_,p_,f_]:=Module[{c,cm},
  If[!(IntegerQ[p]&&PrimeQ[p]),ecMsg[f,"notprime",p];Return[$Failed]];
  If[p==2&&MatchQ[curve,{_,_}],ecMsg[f,"charTwo",p];Return[$Failed]];
  c=ecExtract[curve,f];
  If[c===$Failed,Return[$Failed]];
  cm=ecModP[#,p]&/@c;
  If[MemberQ[cm,$Failed],ecMsg[f,"badcoeffp",Pick[c,cm,$Failed],p];Return[$Failed]];
  If[Mod[ecDisc[cm],p]==0,ecMsg[f,"singularp",c,p];Return[$Failed]];
  cm];

ecFpLongPoint[P_,c_,p_,f_]:=Module[{Q},
  If[P===Infinity,Return[Infinity]];
  If[!ecPointShapeQ[P],ecMsg[f,"badfppoint",P];Return[$Failed]];
  Q=ecFpModPoint[P,p];
  If[Q===$Failed,ecMsg[f,"badcoord",P,p];Return[$Failed]];
  If[!ecFpOnCurveQ[Q,c,p],ecMsg[f,"notOnCurveP",P,c,p];Return[$Failed]];
  Q];

ellipticAddFpLong[P1_,P2_,curve_,p_]:=Module[{c,Q1,Q2},
  c=ecFpLongCurve[curve,p,ECPAddFp];
  If[c===$Failed,Return[$Failed]];
  Q1=ecFpLongPoint[P1,c,p,ECPAddFp];
  If[Q1===$Failed,Return[$Failed]];
  Q2=ecFpLongPoint[P2,c,p,ECPAddFp];
  If[Q2===$Failed,Return[$Failed]];
  fpAddL[Q1,Q2,c,p]];

ellipticMultiplyFpLong[n_,P_,curve_,p_]:=Module[{c,Q},
  If[!IntegerQ[n],ecMsg[ECPMultiplyFp,"badarg","scalar n","an integer",n];Return[$Failed]];
  c=ecFpLongCurve[curve,p,ECPMultiplyFp];
  If[c===$Failed,Return[$Failed]];
  Q=ecFpLongPoint[P,c,p,ECPMultiplyFp];
  If[Q===$Failed,Return[$Failed]];
  fpMulL[n,Q,c,p]];

countFpLong[{a1_,a2_,a3_,a4_,a6_},p_]:=If[p==2,
  1+Total[Table[Count[{0,1},y_/;Mod[y^2+(a1*x+a3)*y-(x^3+a2*x^2+a4*x+a6),2]==0],{x,0,1}]],
  1+Sum[1+JacobiSymbol[Mod[(a1*x+a3)^2+4*(x^3+a2*x^2+a4*x+a6),p],p],{x,0,p-1}]];

ECPSEAPointCount[curve:Except[_Integer],p_Integer]:=Module[{c},
  c=ecFpLongCurve[curve,p,ECPSEAPointCount];
  If[c===$Failed,Return[$Failed]];
  If[p>10^6,Message[ECPSEAPointCount::largep,p];Return[$Failed]];
  countFpLong[c,p]];

(* ===================== Schoof's algorithm for #E(F_p) =====================
   Polynomial arithmetic in F_p[X]/(m) uses the built-in Modulus option. A point of E over the ring F_p[X]/(m),
   where y^2 = f(X), is stored as {Xc, Yc} and means (Xc(X), Yc(X)*y); this is the representation of a generic
   point of the l-torsion when m is the l-th division polynomial. *)

ecSchRem[a_,m_,p_]:=PolynomialMod[PolynomialRemainder[Expand[a],m,ecSchX,Modulus->p],p];
ecSchMul[a_,b_,m_,p_]:=ecSchRem[a*b,m,p];

ecSchPow[a_,e_Integer?NonNegative,m_,p_]:=Module[{r=1,b=ecSchRem[a,m,p]},
  Do[r=ecSchMul[r,r,m,p];If[d===1,r=ecSchMul[r,b,m,p]],{d,IntegerDigits[e,2]}];
  r];

(* inverse in F_p[X]/(m); every inverse taken below is of an element that is nonzero at all roots of m, so a failure
   here is an internal error *)
ecSchInv[a_,m_,p_]:=Module[{aa=ecSchRem[a,m,p],g,s,t},
  If[aa===0,Throw[$Failed,"ecSchoofFail"]];
  {g,{s,t}}=PolynomialExtendedGCD[aa,m,ecSchX,Modulus->p];
  If[PolynomialMod[g,p]=!=1,Throw[$Failed,"ecSchoofFail"]];
  ecSchRem[s,m,p]];

ecSchCoprimeQ[a_,m_,p_]:=Module[{aa=ecSchRem[a,m,p]},
  If[aa===0,False,FreeQ[PolynomialGCD[aa,m,Modulus->p],ecSchX]]];

ecSchMonic[g_,p_]:=Module[{d=Exponent[g,ecSchX]},
  PolynomialMod[g*PowerMod[Coefficient[g,ecSchX,d],-1,p],p]];

(* chord and tangent on y^2 = f(X) over the ring; for the chord the two x-coordinates must differ at every root of m *)
ecSchAdd[{X1_,Y1_},{X2_,Y2_},f_,m_,p_]:=Module[{L,X3,Y3},
  L=ecSchMul[Y2-Y1,ecSchInv[X2-X1,m,p],m,p];
  X3=ecSchRem[ecSchMul[ecSchMul[L,L,m,p],f,m,p]-X1-X2,m,p];
  Y3=ecSchRem[ecSchMul[L,X1-X3,m,p]-Y1,m,p];
  {X3,Y3}];

ecSchDbl[{X1_,Y1_},A_,f_,m_,p_]:=Module[{L,X3,Y3},
  L=ecSchMul[3*ecSchMul[X1,X1,m,p]+A,ecSchInv[ecSchMul[2*Y1,f,m,p],m,p],m,p];
  X3=ecSchRem[ecSchMul[ecSchMul[L,L,m,p],f,m,p]-2*X1,m,p];
  Y3=ecSchRem[ecSchMul[L,X1-X3,m,p]-Y1,m,p];
  {X3,Y3}];

(* {P, 2P, ..., kP} by one doubling and k-2 additions of P *)
ecSchMultiples[P_,k_Integer,A_,f_,m_,p_]:=Module[{out={P},cur=P},
  If[k>=2,cur=ecSchDbl[P,A,f,m,p];AppendTo[out,cur]];
  Do[cur=ecSchAdd[cur,P,f,m,p];AppendTo[out,cur],{j,3,k}];
  out];

(* division polynomial h_n(X) in F_p[X]: psi_n = h_n for odd n and psi_n = 2 y h_n for even n *)
ecSchH[A_,B_,n_Integer,p_]:=Module[{h,f2,k,t1,t2,u,red,X=ecSchX},
  red[e_]:=PolynomialMod[Expand[e],p];
  f2=red[(X^3+A*X+B)^2];
  h=<|0->0,1->1,2->1,
    3->red[3*X^4+6*A*X^2+12*B*X-A^2],
    4->red[2*(X^6+5*A*X^4+20*B*X^3-5*A^2*X^2-4*A*B*X-8*B^2-A^3)]|>;
  Do[
   If[OddQ[mm],
    k=(mm-1)/2;
    t1=red[h[k+2]*h[k]^3];
    t2=red[h[k-1]*h[k+1]^3];
    h[mm]=If[EvenQ[k],red[16*f2*t1-t2],red[t1-16*f2*t2]],
    k=mm/2;
    u=red[h[k+2]*h[k-1]^2-h[k-2]*h[k+1]^2];
    h[mm]=red[h[k]*u]],
   {mm,5,n}];
  h[n]];

(* t mod l for an odd prime l different from p, from the action of the Frobenius phi on E[l]:
   phi^2 P + [q] P = [t] phi P for P in E[l], q = p mod l. *)
ecSchTraceModL[A_,B_,p_,l_]:=Module[
 {m,f,fm,x1,Xp,Yp,Xp2,Yp2,mult,Pq,q=Mod[p,l],w,Pw,g2,S,phi,T,res=$Failed},
 m=ecSchMonic[ecSchH[A,B,l,p],p];
 f=ecSchX^3+A*ecSchX+B;
 fm=ecSchRem[f,m,p];
 x1=ecSchRem[ecSchX,m,p];
 Xp=ecSchPow[x1,p,m,p];
 Yp=ecSchPow[fm,(p-1)/2,m,p];
 Xp2=ecSchPow[Xp,p,m,p];
 Yp2=ecSchPow[fm,(p^2-1)/2,m,p];
 mult=ecSchMultiples[{x1,1},l-1,A,fm,m,p];
 Pq=mult[[q]];
 If[!ecSchCoprimeQ[Xp2-Pq[[1]],m,p],
  (* some P has x(phi^2 P) = x(qP), that is phi^2 P = +-qP: either t = 0, or phi P = +-wP with w^2 = q and t = +-2w *)
  w=SelectFirst[Range[1,l-1],Mod[#^2-q,l]==0&,None];
  res=If[w===None,0,
    (Pw=mult[[w]];
     g2=PolynomialGCD[ecSchRem[Xp-Pw[[1]],m,p],m,Modulus->p];
     Which[
      FreeQ[g2,ecSchX],0,
      ecSchRem[Yp-Pw[[2]],g2,p]===0,Mod[2*w,l],
      ecSchRem[Yp+Pw[[2]],g2,p]===0,Mod[-2*w,l],
      True,$Failed])],
  (* generic case: find tau with phi^2 P + [q] P = [tau] phi P *)
  S=ecSchAdd[{Xp2,Yp2},Pq,fm,m,p];
  phi={Xp,Yp};T=phi;
  Do[
   If[tau==2,T=ecSchDbl[phi,A,fm,m,p],If[tau>2,T=ecSchAdd[T,phi,fm,m,p]]];
   If[ecSchRem[T[[1]]-S[[1]],m,p]===0&&ecSchRem[T[[2]]-S[[2]],m,p]===0,res=tau;Break[]],
   {tau,1,l-1}]];
 res];

ECPSchoofPointCount[curve:Except[_Integer],p_Integer]:=Module[{c,A,B,f,xp,residues,r,tl,M=2,l=3,t0,t},
  c=ecFpLongCurve[curve,p,ECPSchoofPointCount];
  If[c===$Failed,Return[$Failed]];
  If[p<5,Return[countFpLong[c,p]]];
  If[c[[1]]==0&&c[[2]]==0&&c[[3]]==0,
   {A,B}={c[[4]],c[[5]]},
   {A,B}={Mod[-27*c4Of[c],p],Mod[-54*c6Of[c],p]}];
  f=ecSchX^3+A*ecSchX+B;
  r=Catch[
   xp=ecSchPow[ecSchX,p,f,p];
   (* t is even iff f has a root in F_p, i.e. iff gcd(x^p - x, f) is not 1 *)
   residues={{If[ecSchCoprimeQ[xp-ecSchX,f,p],1,0],2}};
   While[M^2<=16*p,
    If[l!=p,
     tl=ecSchTraceModL[A,B,p,l];
     If[tl===$Failed,Throw[$Failed,"ecSchoofFail"]];
     AppendTo[residues,{tl,l}];
     M*=l];
    l=NextPrime[l]];
   residues,
   "ecSchoofFail"];
  If[r===$Failed,ecMsg[ECPSchoofPointCount,"schoofFail",p];Return[$Failed]];
  t0=ChineseRemainder[r[[All,1]],r[[All,2]]];
  t=If[2*t0>M,t0-M,t0];
  If[t^2>4*p,ecMsg[ECPSchoofPointCount,"hasse",t,p];Return[$Failed]];
  p+1-t];

ECPSchoofPointCount[a_Integer,b_Integer,p_Integer]:=ECPSchoofPointCount[{a,b},p];
ECPSchoofPointCount[curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1,ECPSchoofPointCount[curve,fs[[1]]],(ecMsg[ECPSchoofPointCount,"primeOnly",fs];$Failed)];

ECPSEAPointCount[a_Integer,b_Integer,p_Integer]:=ECPSEAPointCount[{a,b},p];

ECPSchoofPointCount::charTwo="y^2 = x^3 + a x + b is singular in characteristic 2; give a long model {a1,a2,a3,a4,a6}.";
ECPSchoofPointCount::schoofFail="Schoof's algorithm failed internally for p = `1`. Please report this curve.";
ECPSchoofPointCount::hasse="The computed trace `1` violates Hasse's bound for p = `2`; this is an internal error. Please report this curve.";
ECPSchoofPointCount::primeOnly="ECPSchoofPointCount works over prime fields F_p only (received the field `1`). For F_(p^r) use ECPSEAPointCount.";

ECPPointQFp[Infinity,curve:Except[_Integer],p_Integer]:=True;
ECPPointQFp[P_,curve:Except[_Integer],p_Integer]:=Module[{c,Q},
  c=ecFpLongCurve[curve,p,ECPPointQFp];
  If[c===$Failed,Return[$Failed]];
  If[!ecPointShapeQ[P],ecMsg[ECPPointQFp,"badfppoint",P];Return[$Failed]];
  Q=ecFpModPoint[P,p];
  If[Q===$Failed,ecMsg[ECPPointQFp,"badcoord",P,p];Return[$Failed]];
  ecFpOnCurveQ[Q,c,p]];

ECPFindPointOrderFp[point_,curve:Except[_Integer],p_Integer]:=Module[{c,Q,n,divs},
  c=ecFpLongCurve[curve,p,ECPFindPointOrderFp];
  If[c===$Failed,Return[$Failed]];
  Q=ecFpLongPoint[point,c,p,ECPFindPointOrderFp];
  If[Q===$Failed,Return[$Failed]];
  If[Q===Infinity,Return[1]];
  If[p>10^6,Message[ECPSEAPointCount::largep,p];Return[$Failed]];
  n=countFpLong[c,p];
  divs=Select[Divisors[n],fpMulL[#,Q,c,p]===Infinity&];
  If[divs==={},Message[ECPFindPointOrderFp::noOrder,point];Return[$Failed]];
  First[divs]];

(* FIX: the short forms used throughout the article: (..., a, p) with b read off the point,
   and (..., a, b, p). *)
ecFpBFromPoint[{x_Integer,y_Integer},a_,p_]:=Mod[y^2-x^3-a*x,p];
ecFpBFromPoint[_,_,_]:=$Failed;
ECPAddFp[P1_,P2_,a_Integer,p_Integer]:=Module[{b=ecFpBFromPoint[If[P1===Infinity,P2,P1],a,p]},
  If[P1===Infinity&&P2===Infinity,Return[Infinity]];
  If[b===$Failed,ecMsg[ECPAddFp,"badfppoint",If[P1===Infinity,P2,P1]];Return[$Failed]];
  ECPAddFp[P1,P2,{a,b},p]];
ECPMultiplyFp[n_,P_,a_Integer,p_Integer]:=Module[{b=ecFpBFromPoint[P,a,p]},
  If[P===Infinity,Return[Infinity]];
  If[b===$Failed,ecMsg[ECPMultiplyFp,"badfppoint",P];Return[$Failed]];
  ECPMultiplyFp[n,P,{a,b},p]];
ECPPointQFp[P_,a_Integer,b_Integer,p_Integer]:=ECPPointQFp[P,{a,b},p];
ECPFindPointOrderFp[P_,a_Integer,b_Integer,p_Integer]:=ECPFindPointOrderFp[P,{a,b},p];
ECPPointOrderFp[P_,args__]:=ECPFindPointOrderFp[P,args];
ECPGroupFp[a_Integer,b_Integer,p_Integer]:=ECPGroupFp[{a,b},p];
ECPFindPointFp[m_Integer,a_Integer,b_Integer,p_Integer]:=ECPFindPointFp[m,{a,b},p];
ECPElGamalEncodeFp[m_Integer,pts:{_,_},a_Integer,b_Integer,p_Integer,n_Integer]:=ECPElGamalEncodeFp[m,pts,{a,b},p,n];
ECPElGamalDecodeFp[s_Integer,cts:{C1_,_},a_Integer,p_Integer]:=Module[{b=ecFpBFromPoint[C1,a,p]},
  If[b===$Failed,ecMsg[ECPElGamalDecodeFp,"badfppoint",C1];Return[$Failed]];
  ECPElGamalDecodeFp[s,cts,{a,b},p]];

ecFpOddLong[curve_,p_,f_]:=Module[{c},
  If[IntegerQ[p]&&PrimeQ[p]&&p==2,ecMsg[f,"koblitzOdd",p];Return[$Failed]];
  ecFpLongCurve[curve,p,f]];

ECPFindPointFp[m_Integer,curve:Except[_Integer],p_Integer,kappa_Integer:100]:=
 Module[{c,xc,L,f0,dd,yc,j,found=False,Y},
  c=ecFpOddLong[curve,p,ECPFindPointFp];
  If[c===$Failed,Return[$Failed]];
  If[kappa<1,ecMsg[ECPFindPointFp,"badarg","kappa","a positive integer",kappa];Return[$Failed]];
  If[m<0||m*kappa+kappa>=p,Message[ECPFindPointFp::outOfRange,m,kappa,p];Return[$Failed]];
  For[j=0,j<kappa,j++,
   xc=m*kappa+j;
   L=Mod[c[[1]]*xc+c[[3]],p];
   f0=Mod[xc^3+c[[2]]*xc^2+c[[4]]*xc+c[[5]],p];
   dd=Mod[L^2+4*f0,p];
   If[dd==0||JacobiSymbol[dd,p]==1,
    If[L==0,
     yc=PowerMod[f0,1/2,p],
     Y=PowerMod[dd,1/2,p];
     yc=Mod[(Y-L)*PowerMod[2,-1,p],p]];
    If[IntegerQ[yc]&&ecFpOnCurveQ[{xc,yc},c,p],found=True;Break[]]]];
  If[found,{xc,yc},Message[ECPFindPointFp::noPoint,m,kappa];$Failed]];

ECPElGamalEncodeFp[m_Integer,{pntP_,pntB_},curve:Except[_Integer],p_Integer,n_Integer,kappa_Integer:100]:=
 Module[{c,P,B,pntM,k,C1,C2},
  c=ecFpOddLong[curve,p,ECPElGamalEncodeFp];
  If[c===$Failed,Return[$Failed]];
  If[n<2,ecMsg[ECPElGamalEncodeFp,"badarg","group-order bound n","an integer >= 2",n];Return[$Failed]];
  If[pntP===Infinity,ecMsg[ECPElGamalEncodeFp,"badfppoint",pntP];Return[$Failed]];
  If[pntB===Infinity,ecMsg[ECPElGamalEncodeFp,"badfppoint",pntB];Return[$Failed]];
  P=ecFpLongPoint[pntP,c,p,ECPElGamalEncodeFp];
  If[P===$Failed,Return[$Failed]];
  B=ecFpLongPoint[pntB,c,p,ECPElGamalEncodeFp];
  If[B===$Failed,Return[$Failed]];
  pntM=ECPFindPointFp[m,c,p,kappa];
  If[pntM===$Failed,Message[ECPElGamalEncodeFp::embedFailed,m];Return[$Failed]];
  k=RandomInteger[{Floor[n/4],n-1}];
  C1=fpMulL[k,P,c,p];
  C2=fpAddL[pntM,fpMulL[k,B,c,p],c,p];
  If[C1===Infinity||C2===Infinity,Message[ECPElGamalEncodeFp::infinity];Return[$Failed]];
  {C1,C2}];

ECPElGamalDecodeFp[s_Integer,{C1_,C2_},curve:Except[_Integer],p_Integer,kappa_Integer:100]:=
 Module[{c,Q1,Q2,pntS,pntM},
  c=ecFpOddLong[curve,p,ECPElGamalDecodeFp];
  If[c===$Failed,Return[$Failed]];
  If[s<1,ecMsg[ECPElGamalDecodeFp,"badarg","private key s","a positive integer",s];Return[$Failed]];
  If[kappa<1,ecMsg[ECPElGamalDecodeFp,"badarg","kappa","a positive integer",kappa];Return[$Failed]];
  If[C1===Infinity,Message[ECPElGamalDecodeFp::infinity];Return[$Failed]];
  Q1=ecFpLongPoint[C1,c,p,ECPElGamalDecodeFp];
  If[Q1===$Failed,Return[$Failed]];
  Q2=ecFpLongPoint[C2,c,p,ECPElGamalDecodeFp];
  If[Q2===$Failed,Return[$Failed]];
  pntS=fpMulL[s,fpNegL[Q1,c,p],c,p];
  pntM=fpAddL[Q2,pntS,c,p];
  If[pntM===Infinity,Message[ECPElGamalDecodeFp::infinity];Return[$Failed]];
  Quotient[pntM[[1]],kappa]];

ClearAll[ecrInv, ecrShift, ecrVal, ecrRes, ecrRepRoot, ecrDbl, ecrSing,
  ecrCount, ecrTate, ecrModelOK];

ecrModelOK[model_, f_] := Which[
  ! (MatchQ[model, {_, _, _, _, _}] && AllTrue[model, IntegerQ]),
   (ecMsg[f, "badmodel", model]; False),
  ecDisc[model] == 0, (ecMsg[f, "singularmodel", model]; False),
  True, True];

ecrInv[{a1_, a2_, a3_, a4_, a6_}] := Module[{b2, b4, b6, b8},
  b2 = a1^2 + 4 a2; b4 = 2 a4 + a1 a3; b6 = a3^2 + 4 a6;
  b8 = a1^2 a6 + 4 a2 a6 - a1 a3 a4 + a2 a3^2 - a4^2;
  {b2, b4, b6, b8, -b2^2 b8 - 8 b4^3 - 27 b6^2 + 9 b2 b4 b6}];

ecrShift[{a1_, a2_, a3_, a4_, a6_}, {r_, s_, t_}] := {
  a1 + 2 s,
  a2 - s a1 + 3 r - s^2,
  a3 + r a1 + 2 t,
  a4 - s a3 + 2 r a2 - (t + r s) a1 + 3 r^2 - 2 s t,
  a6 + r a4 + r^2 a2 + r^3 - t a3 - t^2 - r t a1};

ecrVal[n_Integer, p_] := If[IntegerQ[p] && p > 1, IntegerExponent[n, p], 0];

ecrRes[f_, type_, m_, split_] :=
  <|"f" -> f, "type" -> type, "model" -> m, "split" -> split|>;

ecrRepRoot[P_, T_, p_] := If[p <= 3,
  SelectFirst[Range[0, p - 1],
   Mod[(P /. T -> #), p] == 0 && Mod[(D[P, T] /. T -> #), p] == 0 &],
  Module[{g, c},
   g = PolynomialGCD[P, D[P, T], Modulus -> p];
   c = CoefficientList[g, T];
   Switch[Length[c],
    2, Mod[-c[[1]] PowerMod[c[[2]], -1, p], p],
    3, Mod[-c[[2]] PowerMod[2 c[[3]], -1, p], p],
    _, $Failed]]];

ecrDbl[A_, B_, C_, p_] := If[p == 2,
  Mod[C PowerMod[A, -1, 2], 2],
  Mod[-B PowerMod[2 A, -1, p], p]];

ecrSing[{a1_, a2_, a3_, a4_, a6_}, p_] := If[p == 2,
  SelectFirst[Tuples[{0, 1}, 2],
   Mod[#[[2]]^2 + a1 #[[1]] #[[2]] + a3 #[[2]] - #[[1]]^3 - a2 #[[1]]^2 -
       a4 #[[1]] - a6, 2] == 0 &&
    Mod[a1 #[[1]] + a3, 2] == 0 &&
    Mod[a1 #[[2]] - 3 #[[1]]^2 - 2 a2 #[[1]] - a4, 2] == 0 &],
  Module[{b2, b4, b6, f, x0},
   b2 = a1^2 + 4 a2; b4 = 2 a4 + a1 a3; b6 = a3^2 + 4 a6;
   f = 4 ecrX^3 + b2 ecrX^2 + 2 b4 ecrX + b6;
   x0 = ecrRepRoot[f, ecrX, p];
   {x0, Mod[-(a1 x0 + a3) PowerMod[2, -1, p], p]}]];

ecrTate[model0_List, p_Integer] := Module[
  {m = model0, a1, a2, a3, a4, a6, b2, b4, b6, b8, Dl, v, pt, s,
   P, c, k, A, B, C, trip},
  Catch[
   While[True,
    {b2, b4, b6, b8, Dl} = ecrInv[m]; v = ecrVal[Dl, p];
    If[v == 0, Throw[ecrRes[0, "I0", m, None]]];

    pt = ecrSing[m, p];
    If[! ListQ[pt], Throw[$Failed]];
    m = ecrShift[m, {pt[[1]], 0, pt[[2]]}];
    {a1, a2, a3, a4, a6} = m;
    {b2, b4, b6, b8, Dl} = ecrInv[m];
    If[Mod[b2, p] != 0,
     Throw[ecrRes[1, "I" <> ToString[v], m,
       If[p == 2, EvenQ[a2], JacobiSymbol[Mod[b2, p], p] == 1]]]];

    If[Mod[a6, p^2] != 0, Throw[ecrRes[v, "II", m, None]]];
    If[Mod[b8, p^3] != 0, Throw[ecrRes[v - 1, "III", m, None]]];
    If[Mod[b6, p^3] != 0, Throw[ecrRes[v - 2, "IV", m, None]]];

    If[p == 2,
     m = ecrShift[m, {0, Mod[a2, 2], 0}];
     {a1, a2, a3, a4, a6} = m;
     m = ecrShift[m, {0, 0, 2 Mod[a6/4, 2]}],
     s = Mod[-a1 PowerMod[2, -1, p], p];
     m = ecrShift[m, {0, s, 0}];
     {a1, a2, a3, a4, a6} = m;
     m = ecrShift[m, {0, 0, Mod[-a3 PowerMod[2, -1, p^2], p^2]}]];
    {a1, a2, a3, a4, a6} = m;
    If[! (Mod[a1, p] == 0 && Mod[a2, p] == 0 && Mod[a3, p^2] == 0 &&
        Mod[a4, p^2] == 0 && Mod[a6, p^3] == 0), Throw[$Failed]];

    P = ecrT^3 + (a2/p) ecrT^2 + (a4/p^2) ecrT + a6/p^3;
    If[Mod[Discriminant[P, ecrT], p] != 0,
     Throw[ecrRes[v - 4, "I0*", m, None]]];
    c = ecrRepRoot[P, ecrT, p];
    If[! IntegerQ[c], Throw[$Failed]];
    trip = (PolynomialMod[Expand[P - (ecrT - c)^3], p] === 0);
    m = ecrShift[m, {p c, 0, 0}];

    If[! trip,

     k = 1;
     While[True,
      If[k > v + 3, Throw[$Failed]];
      {a1, a2, a3, a4, a6} = m;
      B = a3/p^(k + 1); C = -a6/p^(2 k + 2);
      If[! (IntegerQ[B] && IntegerQ[C]), Throw[$Failed]];
      If[Mod[B^2 - 4 C, p] != 0,
       Throw[ecrRes[v - 2 k - 3, "I" <> ToString[2 k - 1] <> "*", m, None]]];
      m = ecrShift[m, {0, 0, p^(k + 1) ecrDbl[1, B, C, p]}];
      {a1, a2, a3, a4, a6} = m;
      A = a2/p; B = a4/p^(k + 2); C = a6/p^(2 k + 3);
      If[! (IntegerQ[A] && IntegerQ[B] && IntegerQ[C]), Throw[$Failed]];
      If[Mod[B^2 - 4 A C, p] != 0,
       Throw[ecrRes[v - 2 k - 4, "I" <> ToString[2 k] <> "*", m, None]]];
      m = ecrShift[m, {p^(k + 1) ecrDbl[A, B, C, p], 0, 0}];
      k++],

     {a1, a2, a3, a4, a6} = m;
     B = a3/p^2; C = -a6/p^4;
     If[! (IntegerQ[B] && IntegerQ[C]), Throw[$Failed]];
     If[Mod[B^2 - 4 C, p] != 0, Throw[ecrRes[v - 6, "IV*", m, None]]];
     m = ecrShift[m, {0, 0, p^2 ecrDbl[1, B, C, p]}];
     {a1, a2, a3, a4, a6} = m;
     If[Mod[a4, p^4] != 0, Throw[ecrRes[v - 7, "III*", m, None]]];
     If[Mod[a6, p^6] != 0, Throw[ecrRes[v - 8, "II*", m, None]]];

     m = {a1/p, a2/p^2, a3/p^3, a4/p^4, a6/p^6}]]
   ]];

ECPTate[model_, p_] := Which[
  ! ecrModelOK[model, ECPTate], $Failed,
  ! (IntegerQ[p] && PrimeQ[p]), (ecMsg[ECPTate, "badprime", p]; $Failed),
  True, ecrTate[model, p]];

ECPLocalData[model_] := Module[{Dl},
  If[! ecrModelOK[model, ECPLocalData], Return[$Failed]];
  Dl = ecrInv[model][[5]];
  Association[# -> ecrTate[model, #] & /@ FactorInteger[Abs[Dl]][[All, 1]]]];

ECPConductor[model_] := Module[{loc},
  If[! ecrModelOK[model, ECPConductor], Return[$Failed]];
  loc = ECPLocalData[model];
  If[loc === $Failed || ! AllTrue[Values[loc], AssociationQ],
   ecMsg[ECPConductor, "tatefail", model]; $Failed,
   Times @@ KeyValueMap[#1^#2["f"] &, loc]]];

ecrCount[{a1_, a2_, a3_, a4_, a6_}, p_] := If[p == 2,
  2 - Count[Tuples[{0, 1}, 2], {u_, w_} /;
     EvenQ[w^2 + a1 u w + a3 w - u^3 - a2 u^2 - a4 u - a6]],
  -Sum[JacobiSymbol[Mod[(a1 t + a3)^2 + 4 (t^3 + a2 t^2 + a4 t + a6), p], p],
    {t, 0, p - 1}]];

ECPAnalyticRank[model:{_,_,_,_,_}, prec_Integer: 40] := Module[
  {loc, N0, Mn, ap, apk, an, nz, sq, th, w, wr, lam, yy, pts, vals, cf, rank},
  If[! ecrModelOK[model, ECPAnalyticRank], Return[$Failed]];
  If[prec < 20, ecMsg[ECPAnalyticRank, "badprec", prec]; Return[$Failed]];
  loc = ECPLocalData[model];
  (* SPEEDUP: the conductor is read off the local data just computed, instead of calling ECPConductor,
     which would run Tate's algorithm at every bad prime a second time *)
  N0 = If[AssociationQ[loc] && AllTrue[Values[loc], AssociationQ],
    Times @@ KeyValueMap[#1^#2["f"] &, loc],
    ecMsg[ECPAnalyticRank, "tatefail", model]; $Failed];
  If[! IntegerQ[N0],
   $Failed,
   (* SPEEDUP: the terms decay like Exp[-2 Pi n/Sqrt[N]], so prec digits need about
      prec Log[10] Sqrt[N]/(2 Pi) terms (~14.7 Sqrt[N] at prec = 40, ~7.3 Sqrt[N] at prec = 20)
      instead of the fixed 20 Sqrt[N]; the +5 and +20 are a safety margin *)
   Mn = Ceiling[(prec Log[10] + 5) Sqrt[N0]/(2 Pi)] + 20;

   ap[p_] := ap[p] = If[KeyExistsQ[loc, p],
     Which[loc[p]["f"] == 1, If[loc[p]["split"], 1, -1],
      loc[p]["f"] >= 2, 0,
      True, ecrCount[loc[p]["model"], p]],
     ecrCount[model, p]];
   apk[p_, 0] = 1;
   apk[p_, 1] := ap[p];
   apk[p_, k_] := apk[p, k] = If[Mod[N0, p] == 0, ap[p]^k,
     ap[p] apk[p, k - 1] - p apk[p, k - 2]];
   an = Table[If[n == 1, 1, Times @@ (apk @@@ FactorInteger[n])], {n, Mn}];

   sq = Sqrt[N[N0, prec]];
   (* SPEEDUP: only the n with a_n =!= 0 are summed (many a_n vanish) *)
   nz = Select[Range[Mn], an[[#]] =!= 0 &];
   th[y_] := Sum[an[[n]] Exp[-2 Pi n y/sq], {n, nz}];
   yy = N[13/10, prec];
   wr = th[1/yy]/(yy^2 th[yy]);
   w = Round[wr];
   If[Abs[wr - w] > 10^-10 || ! MemberQ[{1, -1}, w],
    Print["Warning: root number came out as ", N[wr, 12],
     " (not +-1): wrong conductor / a_n?"]];

   lam[s_?NumericQ] := Sum[
     With[{x = sq/(2 Pi n)},
      an[[n]] (x^s Gamma[s, 1/x] + w x^(2 - s) Gamma[2 - s, 1/x])],
     {n, nz}];

   pts = Table[N[j/50, prec], {j, -6, 6}];
   vals = lam[1 + #] & /@ pts;
   cf = LinearSolve[Table[If[j == 0, 1, pts[[i]]^j], {i, 13}, {j, 0, 12}], vals];
   rank = FirstPosition[Abs[cf], _?(# > 10^-8 &), {$Failed}][[1]];
   If[IntegerQ[rank], rank = rank - 1];
   If[IntegerQ[rank] && Mod[rank, 2] != If[w == 1, 0, 1],
    Print["Warning: rank parity disagrees with root number."]];
   Association["Rank" -> rank, "Parity" -> w, "Conductor" -> N0]]];

(* FIX: short pairs, equations, Associations and Automatic are accepted, as documented *)
ECPAnalyticRank[curve:Except[{_,_,_,_,_}|_Integer], prec_Integer: 40] := Module[{c = ecLong[curve, ECPAnalyticRank]},
  If[c === $Failed, $Failed, ECPAnalyticRank[c, prec]]];
ecInstallMessages[{ECPAnalyticRank}, ecCurveMessages];

(* 18. FINITE FIELDS F_(p^r) *)

$ECPFqTableLimit=10^31;

ecFqPolyMulMod[a_List,b_List,fc_List,p_Integer]:=Module[{r=Length[a],c,t,K,i,j},
  c=ConstantArray[0,2*r-1];
  Do[c[[i+j-1]]=c[[i+j-1]]+a[[i]]*b[[j]],{i,r},{j,r}];
  Do[t=Mod[c[[K]],p];
   If[t!=0,Do[c[[K-r+i-1]]=c[[K-r+i-1]]-t*fc[[i]],{i,r}]],
   {K,2*r-1,r+1,-1}];
  Mod[Take[c,r],p]];

ecFqXPow[n_Integer,fc_List,p_Integer]:=Module[{r=Length[fc],res,base,k=n},
  res=Prepend[ConstantArray[0,r-1],1];
  base=If[r==1,{Mod[-fc[[1]],p]},ReplacePart[ConstantArray[0,r],2->1]];
  While[k>0,
   If[OddQ[k],res=ecFqPolyMulMod[res,base,fc,p]];
   base=ecFqPolyMulMod[base,base,fc,p];
   k=Floor[k/2]];
  res];

ecFqPrimitiveQ[fc_List,p_Integer,r_Integer]:=Module[{q=p^r,one=Prepend[ConstantArray[0,r-1],1]},
  ecFqXPow[q-1,fc,p]===one&&
  AllTrue[DeleteCases[First/@FactorInteger[q-1],1],ecFqXPow[(q-1)/#,fc,p]=!=one&]];

ecFqFindPoly[p_Integer,r_Integer]:=Module[{n,fc,found=$Failed},
  For[n=1,n<p^r&&found===$Failed,n++,
   If[Mod[n,p]!=0,
    fc=Reverse[IntegerDigits[n,p,r]];
    If[ecFqPrimitiveQ[fc,p,r],found=fc]]];
  found];

ecFqBuild[p_Integer,r_Integer]:=Module[{q=p^r,m,fc,v,e,expT,logT,zech,k,top,d0,e2,pw},
  m=q-1;
  fc=ecFqFindPoly[p,r];
  If[fc===$Failed,Return[$Failed]];
  expT=ConstantArray[0,m];
  logT=ConstantArray[-1,q];
  v=Prepend[ConstantArray[0,r-1],1];
  pw=p^Range[0,r-1];
  Do[
   e=v . pw;
   expT[[k+1]]=e;
   logT[[e+1]]=k;
   top=v[[r]];
   v=Mod[Prepend[Most[v],0]-top*fc,p],
   {k,0,m-1}];
  zech=ConstantArray[-1,m];
  Do[
   e=expT[[k+1]];
   d0=Mod[e,p];
   e2=e-d0+Mod[d0+1,p];
   zech[[k+1]]=logT[[e2+1]],
   {k,0,m-1}];
  <|"p"->p,"r"->r,"q"->q,"m"->m,"poly"->fc,"exp"->expT,"log"->logT,"zech"->zech|>];

ecFqField[p_Integer,r_Integer]:=(ecFqField[p,r]=ecFqBuild[p,r]);

ecFqCheckSpec[fs_,f_]:=If[MatchQ[fs,{_Integer,_Integer}]&&fs[[1]]>1&&PrimeQ[fs[[1]]]&&fs[[2]]>=1,True,
  (ecMsg[f,"badfield",fs];False)];

ecFqSpec[fs_,f_]:=Module[{F},
  If[!ecFqCheckSpec[fs,f],Return[$Failed]];
  If[fs[[1]]^fs[[2]]>$ECPFqTableLimit,ecMsg[f,"fieldTooBig",fs[[1]]^fs[[2]],$ECPFqTableLimit];Return[$Failed]];
  F=ecFqField[fs[[1]],fs[[2]]];
  If[F===$Failed,ecMsg[f,"badfield",fs]];
  F];

fqAdd[F_,a_,b_]:=Which[a<0,b,b<0,a,
  True,With[{z=F["zech"][[Mod[b-a,F["m"]]+1]]},If[z<0,-1,Mod[a+z,F["m"]]]]];
fqMul[F_,a_,b_]:=If[a<0||b<0,-1,Mod[a+b,F["m"]]];
fqInv[F_,a_]:=Mod[-a,F["m"]];
fqNeg[F_,a_]:=If[a<0,-1,If[F["p"]==2,a,Mod[a+F["m"]/2,F["m"]]]];
fqSub[F_,a_,b_]:=fqAdd[F,a,fqNeg[F,b]];
fqInt[F_,n_Integer]:=With[{k=Mod[n,F["p"]]},If[k==0,-1,F["log"][[k+1]]]];
fqPow[F_,a_,n_Integer]:=Which[n==0,0,a<0,-1,True,Mod[a*n,F["m"]]];
fqScale[F_,n_Integer,a_]:=fqMul[F,fqInt[F,n],a];
fqSum[F_,l_List]:=Fold[fqAdd[F,#1,#2]&,-1,l];
fqProd[F_,l_List]:=Fold[fqMul[F,#1,#2]&,0,l];

fqTrace2[F_,c_]:=fqSum[F,Table[fqPow[F,c,2^i],{i,0,F["r"]-1}]];

fqGamma[F_]:=SelectFirst[Range[0,F["m"]-1],fqTrace2[F,#]>=0&];

ecFqOut[F_,a_]:=Which[a<0,0,a==0,1,True,Power[Symbol["g"],a]];
ecFqOutList[F_,l_List]:=ecFqOut[F,#]&/@l;
ecFqOutPt[F_,P_]:=If[P===Infinity,Infinity,ecFqOut[F,#]&/@P];

ecFqParse[F_,expr_]:=Catch[Module[{vs,v,terms,t,c,k,n,tot=-1},
  vs=Variables[expr];
  If[Length[vs]>1,Throw[$Failed]];
  If[Length[vs]==0,
   n=ecModP[expr,F["p"]];
   Throw[If[n===$Failed,$Failed,fqInt[F,n]]]];
  v=First[vs];
  terms=Expand[expr];
  terms=If[Head[terms]===Plus,List@@terms,{terms}];
  Do[
   c=t/.v->1;
   k=Exponent[t,v];
   If[!(IntegerQ[k]&&Together[t/(c*v^k)]===1),Throw[$Failed]];
   n=ecModP[c,F["p"]];
   If[n===$Failed,Throw[$Failed]];
   tot=fqAdd[F,tot,fqMul[F,fqInt[F,n],Mod[k,F["m"]]]],
   {t,terms}];
  tot]];

(* FIX: elements were parsed one at a time, so ECPFqAdd[g, h, ...] silently read both g and h as the
   generator. All elements given together must now use the same symbol. *)
ecFqOneSymbolQ[l_]:=Length[Variables[l]]<=1;
ecFqParseList[F_,l_List,f_]:=Module[{codes},
  If[!ecFqOneSymbolQ[l],ecMsg[f,"badelem",l,F["q"]];Return[$Failed]];
  codes=ecFqParse[F,#]&/@l;
  If[MemberQ[codes,$Failed],ecMsg[f,"badelem",Pick[l,codes,$Failed],F["q"]];$Failed,codes]];

fqInvariants[F_,{a1_,a2_,a3_,a4_,a6_}]:=Module[{sm,mu,sc,ng,b2,b4,b6,b8,c4,c6,d},
  sm[l_List]:=fqSum[F,l];
  mu[x__]:=fqProd[F,{x}];
  sc[n_,x_]:=fqScale[F,n,x];
  ng[x_]:=fqNeg[F,x];
  b2=sm[{mu[a1,a1],sc[4,a2]}];
  b4=sm[{sc[2,a4],mu[a1,a3]}];
  b6=sm[{mu[a3,a3],sc[4,a6]}];
  b8=sm[{mu[a1,a1,a6],sc[4,mu[a2,a6]],ng[mu[a1,a3,a4]],mu[a2,a3,a3],ng[mu[a4,a4]]}];
  c4=sm[{mu[b2,b2],sc[-24,b4]}];
  c6=sm[{ng[mu[b2,b2,b2]],sc[36,mu[b2,b4]],sc[-216,b6]}];
  d=sm[{ng[mu[b2,b2,b8]],sc[-8,mu[b4,b4,b4]],sc[-27,mu[b6,b6]],sc[9,mu[b2,b4,b6]]}];
  <|"b2"->b2,"b4"->b4,"b6"->b6,"b8"->b8,"c4"->c4,"c6"->c6,"D"->d|>];

fqJ[F_,c_]:=With[{i=fqInvariants[F,c]},fqMul[F,fqProd[F,{i["c4"],i["c4"],i["c4"]}],fqInv[F,i["D"]]]];

fqTransform[F_,{a1_,a2_,a3_,a4_,a6_},{u_,r_,s_,t_}]:=Module[{sm,mu,sc,ng,ui,n1,n2,n3,n4,n6},
  sm[l_List]:=fqSum[F,l];
  mu[x__]:=fqProd[F,{x}];
  sc[n_,x_]:=fqScale[F,n,x];
  ng[x_]:=fqNeg[F,x];
  ui=fqInv[F,u];
  n1=mu[sm[{a1,sc[2,s]}],ui];
  n2=mu[sm[{a2,ng[mu[s,a1]],sc[3,r],ng[mu[s,s]]}],fqPow[F,ui,2]];
  n3=mu[sm[{a3,mu[r,a1],sc[2,t]}],fqPow[F,ui,3]];
  n4=mu[sm[{a4,ng[mu[s,a3]],sc[2,mu[r,a2]],ng[mu[fqAdd[F,t,mu[r,s]],a1]],sc[3,mu[r,r]],ng[sc[2,mu[s,t]]]}],fqPow[F,ui,4]];
  n6=mu[sm[{a6,mu[r,a4],mu[r,r,a2],fqPow[F,r,3],ng[mu[t,a3]],ng[mu[t,t]],ng[mu[r,t,a1]]}],fqPow[F,ui,6]];
  {n1,n2,n3,n4,n6}];

fqCompose[F_,{u1_,r1_,s1_,t1_},{u2_,r2_,s2_,t2_}]:=
  {fqMul[F,u1,u2],
   fqAdd[F,r1,fqMul[F,fqPow[F,u1,2],r2]],
   fqAdd[F,s1,fqMul[F,u1,s2]],
   fqSum[F,{t1,fqProd[F,{fqPow[F,u1,2],s1,r2}],fqMul[F,fqPow[F,u1,3],t2]}]};

fqIdentity={0,-1,-1,-1};

fqNegPt[F_,c_,Infinity]:=Infinity;
fqNegPt[F_,{a1_,a2_,a3_,a4_,a6_},{x_,y_}]:={x,fqNeg[F,fqSum[F,{y,fqMul[F,a1,x],a3}]]};

fqAddPt[F_,c_,Infinity,Q_]:=Q;
fqAddPt[F_,c_,P_,Infinity]:=P;
fqAddPt[F_,{a1_,a2_,a3_,a4_,a6_},{x1_,y1_},{x2_,y2_}]:=Module[{lam,nu,x3,y3,den},
  If[x1==x2,
   If[fqSum[F,{y1,y2,fqMul[F,a1,x2],a3}]<0,Return[Infinity]];
   den=fqSum[F,{fqScale[F,2,y1],fqMul[F,a1,x1],a3}];
   lam=fqMul[F,
     fqSum[F,{fqScale[F,3,fqMul[F,x1,x1]],fqScale[F,2,fqMul[F,a2,x1]],a4,fqNeg[F,fqMul[F,a1,y1]]}],
     fqInv[F,den]],
   lam=fqMul[F,fqSub[F,y2,y1],fqInv[F,fqSub[F,x2,x1]]]];
  nu=fqSub[F,y1,fqMul[F,lam,x1]];
  x3=fqSum[F,{fqMul[F,lam,lam],fqMul[F,a1,lam],fqNeg[F,a2],fqNeg[F,x1],fqNeg[F,x2]}];
  y3=fqSub[F,fqNeg[F,fqMul[F,fqAdd[F,lam,a1],x3]],fqAdd[F,nu,a3]];
  {x3,y3}];

fqMulPt[F_,c_,n_Integer,P_]:=Module[{k,base,res=Infinity},
  If[n==0||P===Infinity,Return[Infinity]];
  k=Abs[n];
  base=If[n>0,P,fqNegPt[F,c,P]];
  While[k>0,
   If[OddQ[k],res=fqAddPt[F,c,res,base]];
   base=fqAddPt[F,c,base,base];
   k=Floor[k/2]];
  res];

fqOnCurve[F_,{a1_,a2_,a3_,a4_,a6_},{x_,y_}]:=Module[{lhs,rhs},
  lhs=fqSum[F,{fqMul[F,y,y],fqProd[F,{a1,x,y}],fqMul[F,a3,y]}];
  rhs=fqSum[F,{fqPow[F,x,3],fqProd[F,{a2,x,x}],fqMul[F,a4,x],a6}];
  lhs==rhs];

fqCount[F_,{a1_,a2_,a3_,a4_,a6_}]:=Module[{tot=1,L,f0,dd,cc,x},
  Do[
   L=fqAdd[F,fqMul[F,a1,x],a3];
   f0=fqSum[F,{fqPow[F,x,3],fqProd[F,{a2,x,x}],fqMul[F,a4,x],a6}];
   If[F["p"]!=2,
    dd=fqAdd[F,fqMul[F,L,L],fqScale[F,4,f0]];
    tot=tot+If[dd<0,1,If[EvenQ[dd],2,0]],
    If[L<0,
     tot=tot+1,
     cc=fqMul[F,f0,fqInv[F,fqMul[F,L,L]]];
     If[fqTrace2[F,cc]<0,tot=tot+2]]],
   {x,Prepend[Range[0,F["m"]-1],-1]}];
  tot];

fqPrimeCoeffs[F_,c_List]:=Module[{vals=If[#<0,0,F["exp"][[#+1]]]&/@c},
  If[AllTrue[vals,#<F["p"]&],vals,None]];

fqLucasCount[cm_List,p_Integer,r_Integer]:=Module[{n1=countFpLong[cm,p],t,s0=2,s1,tmp},
  t=p+1-n1;s1=t;
  Do[tmp=t*s1-p*s0;s0=s1;s1=tmp,{r-1}];
  p^r+1-s1];

ecFqGroupOrder[F_,c_,f_]:=Module[{ints=fqPrimeCoeffs[F,c]},
  If[ints=!=None&&F["p"]<=10^6,fqLucasCount[ints,F["p"],F["r"]],fqCount[F,c]]];

ecFqExtractExpr[curve_,F_,f_]:=Module[{expr,xs,ys,rules,allowed,stray,cf,cy2,cx3,cod,vals,k,bad},
  If[!(Head[curve]===Equal||(!AtomQ[curve]&&Variables[curve]=!={})),
   ecMsg[f,"badcurve",curve];Return[$Failed]];
  expr=Expand[If[Head[curve]===Equal,curve[[1]]-curve[[2]],curve]];
  {xs,ys}=detectXY[expr];
  If[!PolynomialQ[expr,{xs,ys}],
   ecMsg[f,"notWeierstrass","it is not a polynomial in "<>ToString[xs]<>" and "<>ToString[ys]];Return[$Failed]];
  rules=CoefficientRules[expr,{xs,ys}];
  allowed={{0,0},{1,0},{2,0},{3,0},{0,1},{1,1},{0,2}};
  stray=Complement[rules[[All,1]],allowed];
  If[stray=!={},
   ecMsg[f,"notWeierstrass","unexpected monomial(s) x^i y^j for {i,j} in "<>ToString[stray]];Return[$Failed]];
  cf[i_,j_]:=Coefficient[Coefficient[expr,xs,i],ys,j];
  vals=cf@@@{{1,1},{2,0},{0,1},{1,0},{0,0},{0,2},{3,0}};
  cod=ecFqParse[F,#]&/@vals;
  If[MemberQ[cod,$Failed],ecMsg[f,"badelem",Pick[vals,cod,$Failed],F["q"]];Return[$Failed]];
  cy2=cod[[6]];cx3=cod[[7]];
  If[cy2<0,ecMsg[f,"notWeierstrass","there is no y^2 term"];Return[$Failed]];
  If[fqAdd[F,fqMul[F,cx3,fqInv[F,cy2]],0]>=0,
   ecMsg[f,"notWeierstrass","with the y^2 coefficient scaled to 1 the x^3 coefficient on the right-hand side must be 1"];Return[$Failed]];
  k=fqInv[F,cy2];
  {fqMul[F,cod[[1]],k],fqNeg[F,fqMul[F,cod[[2]],k]],fqMul[F,cod[[3]],k],
   fqNeg[F,fqMul[F,cod[[4]],k]],fqNeg[F,fqMul[F,cod[[5]],k]]}];

ecFqCurve[curve_,F_,f_]:=Module[{raw,c},
  c=Which[
   curve===Automatic,
    raw=ecSession[f];If[raw===$Failed,$Failed,ecFqParseList[F,raw,f]],
   MatchQ[curve,{_,_}],ecFqParseList[F,{0,0,0,curve[[1]],curve[[2]]},f],
   MatchQ[curve,{_,_,_,_,_}],ecFqParseList[F,curve,f],
   AssociationQ[curve],
    raw=ecExtractAssoc[curve,f];If[raw===$Failed,$Failed,ecFqParseList[F,raw,f]],
   True,ecFqExtractExpr[curve,F,f]];
  If[c===$Failed,Return[$Failed]];
  If[fqInvariants[F,c]["D"]<0,ecMsg[f,"singularq",ecFqOutList[F,c],F["q"]];Return[$Failed]];
  c];

ecFqPrep[curve_,fs_,f_]:=Module[{F,c},
  F=ecFqSpec[fs,f];
  If[F===$Failed,Return[$Failed]];
  c=ecFqCurve[curve,F,f];
  If[c===$Failed,Return[$Failed]];
  {F,c}];

ecFqPoint[P_,F_,c_,f_]:=Module[{x,y},
  If[P===Infinity,Return[Infinity]];
  If[!MatchQ[P,{_,_}],ecMsg[f,"badfqpoint",P];Return[$Failed]];
  If[!ecFqOneSymbolQ[P],ecMsg[f,"badelem",P,F["q"]];Return[$Failed]];
  x=ecFqParse[F,P[[1]]];y=ecFqParse[F,P[[2]]];
  If[x===$Failed||y===$Failed,ecMsg[f,"badelem",P,F["q"]];Return[$Failed]];
  If[!fqOnCurve[F,c,{x,y}],ecMsg[f,"notOnCurveP",P,ecFqOutList[F,c],F["q"]];Return[$Failed]];
  {x,y}];

ECPAddFp[P1_,P2_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPAddFp[P1,P2,curve,fs[[1]]],ecFqAddCmd[P1,P2,curve,fs]];

ecFqAddCmd[P1_,P2_,curve_,fs_]:=Module[{prep,F,c,Q1,Q2},
  prep=ecFqPrep[curve,fs,ECPAddFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  Q1=ecFqPoint[P1,F,c,ECPAddFp];If[Q1===$Failed,Return[$Failed]];
  Q2=ecFqPoint[P2,F,c,ECPAddFp];If[Q2===$Failed,Return[$Failed]];
  ecFqOutPt[F,fqAddPt[F,c,Q1,Q2]]];

ECPMultiplyFp[n_,P_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPMultiplyFp[n,P,curve,fs[[1]]],ecFqMulCmd[n,P,curve,fs]];

ecFqMulCmd[n_,P_,curve_,fs_]:=Module[{prep,F,c,Q},
  If[!IntegerQ[n],ecMsg[ECPMultiplyFp,"badarg","scalar n","an integer",n];Return[$Failed]];
  prep=ecFqPrep[curve,fs,ECPMultiplyFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  Q=ecFqPoint[P,F,c,ECPMultiplyFp];If[Q===$Failed,Return[$Failed]];
  ecFqOutPt[F,fqMulPt[F,c,n,Q]]];

ECPPointQFp[P_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPPointQFp[P,curve,fs[[1]]],ecFqPointQCmd[P,curve,fs]];

ecFqPointQCmd[P_,curve_,fs_]:=Module[{prep,F,c,x,y},
  prep=ecFqPrep[curve,fs,ECPPointQFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  If[P===Infinity,Return[True]];
  If[!MatchQ[P,{_,_}],ecMsg[ECPPointQFp,"badfqpoint",P];Return[$Failed]];
  x=ecFqParse[F,P[[1]]];y=ecFqParse[F,P[[2]]];
  If[x===$Failed||y===$Failed,ecMsg[ECPPointQFp,"badelem",P,F["q"]];Return[$Failed]];
  fqOnCurve[F,c,{x,y}]];

ecFqIntCurve[curve_]:=Module[{sess,l},
  l=Which[
   curve===Automatic,
    sess=If[AssociationQ[ECPack`$ECPCurrentEC]&&KeyExistsQ[ECPack`$ECPCurrentEC,"Coefficients"],
      ECPack`$ECPCurrentEC["Coefficients"],None];
    If[sess===None,None,sess],
   MatchQ[curve,{_Integer,_Integer}],{0,0,0,curve[[1]],curve[[2]]},
   MatchQ[curve,{_Integer,_Integer,_Integer,_Integer,_Integer}],curve,
   AssociationQ[curve]&&KeyExistsQ[curve,"Coefficients"]&&MatchQ[curve["Coefficients"],{_,_,_,_,_}],curve["Coefficients"],
   True,None];
  If[ListQ[l]&&Length[l]==5&&AllTrue[l,IntegerQ],l,None]];

ECPSEAPointCount[curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPSEAPointCount[curve,fs[[1]]],ecFqCountCmd[curve,fs]];

ecFqCountCmd[curve_,fs_]:=Module[{ints,p,r,cm,prep,F,c},
  If[!ecFqCheckSpec[fs,ECPSEAPointCount],Return[$Failed]];
  {p,r}=fs;
  ints=ecFqIntCurve[curve];
  If[ints=!=None,

   If[p>10^6,Message[ECPSEAPointCount::largep,p];Return[$Failed]];
   cm=Mod[ints,p];
   If[Mod[ecDisc[cm],p]==0,ecMsg[ECPSEAPointCount,"singularq",cm,p^r];Return[$Failed]];
   Return[fqLucasCount[cm,p,r]]];
  prep=ecFqPrep[curve,fs,ECPSEAPointCount];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  ecFqGroupOrder[F,c,ECPSEAPointCount]];

ECPFindPointOrderFp[P_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPFindPointOrderFp[P,curve,fs[[1]]],ecFqOrderCmd[P,curve,fs]];

ecFqOrderCmd[P_,curve_,fs_]:=Module[{prep,F,c,Q,n,divs},
  prep=ecFqPrep[curve,fs,ECPFindPointOrderFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  Q=ecFqPoint[P,F,c,ECPFindPointOrderFp];If[Q===$Failed,Return[$Failed]];
  If[Q===Infinity,Return[1]];
  n=ecFqGroupOrder[F,c,ECPFindPointOrderFp];
  divs=Select[Divisors[n],fqMulPt[F,c,#,Q]===Infinity&];
  If[divs==={},Message[ECPFindPointOrderFp::noOrder,P];Return[$Failed]];
  First[divs]];

ecFqKoblitzRefuse[f_,fs_]:=(ecMsg[f,"fqKoblitz",fs];$Failed);

ECPFindPointFp[m_Integer,curve_,fs:{_Integer,_Integer},kappa_Integer:100]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPFindPointFp[m,curve,fs[[1]],kappa],ecFqKoblitzRefuse[ECPFindPointFp,fs]];

ECPElGamalEncodeFp[m_Integer,pts:{_,_},curve_,fs:{_Integer,_Integer},n_Integer,kappa_Integer:100]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPElGamalEncodeFp[m,pts,curve,fs[[1]],n,kappa],ecFqKoblitzRefuse[ECPElGamalEncodeFp,fs]];

ECPElGamalDecodeFp[s_Integer,cts:{_,_},curve_,fs:{_Integer,_Integer},kappa_Integer:100]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPElGamalDecodeFp[s,cts,curve,fs[[1]],kappa],ecFqKoblitzRefuse[ECPElGamalDecodeFp,fs]];

fqApply[F_,{c_,T_},T2_]:={fqTransform[F,c,T2],fqCompose[F,T,T2]};

ecFqNormalCore[F_,c_]:=Module[{p=F["p"],st={c,fqIdentity},a1,a2n,r,s,t,cc,target,gam=None,case,half},
  half=fqInv[F,fqInt[F,2]];
  Which[
   p==3,
    s=fqMul[F,fqNeg[F,c[[1]]],half];
    st=fqApply[F,st,{0,-1,s,-1}];
    a2n=st[[1,2]];
    If[a2n>=0,
     r=fqNeg[F,fqMul[F,st[[1,4]],fqInv[F,fqMul[F,fqInt[F,2],a2n]]]];
     st=fqApply[F,st,{0,r,-1,-1}];
     t=fqMul[F,fqNeg[F,st[[1,3]]],half];
     st=fqApply[F,st,{0,-1,-1,t}];
     case="ordinary (b2 != 0): y^2=x^3+a2 x^2+a6",
     t=fqMul[F,fqNeg[F,st[[1,3]]],half];
     st=fqApply[F,st,{0,-1,-1,t}];
     case="supersingular (b2 = 0): y^2=x^3+a4 x+a6"],
   True,
    If[c[[1]]>=0,
     st=fqApply[F,st,{c[[1]],-1,-1,-1}];
     r=fqNeg[F,fqMul[F,st[[1,3]],fqInv[F,st[[1,1]]]]];
     st=fqApply[F,st,{0,r,-1,-1}];
     t=st[[1,4]];
     a2n=st[[1,2]];
     gam=fqGamma[F];
     target=If[fqTrace2[F,a2n]<0,-1,gam];
     cc=fqAdd[F,a2n,target];
     s=SelectFirst[Prepend[Range[0,F["m"]-1],-1],fqAdd[F,fqMul[F,#,#],#]==cc&];
     If[s===Missing["NotFound"],Return[$Failed]];
     st=fqApply[F,st,{0,-1,s,t}];
     case="ordinary (a1 != 0): y^2+xy=x^3+a2 x^2+a6 with a2 in {0, gamma}, gamma of absolute trace 1",
     r=fqNeg[F,c[[2]]];
     st=fqApply[F,st,{0,r,-1,-1}];
     case="supersingular (a1 = 0): y^2+a3 y=x^3+a4 x+a6"]];
  <|"coeffs"->st[[1]],"T"->st[[2]],"case"->case,"gamma"->gam|>];

ecFqShortCore[F_,c_]:=Module[{p=F["p"],i,r,s,t,T,nc,half,case},
  If[p>3,
   half=fqInv[F,fqInt[F,2]];
   i=fqInvariants[F,c];
   r=fqMul[F,fqNeg[F,i["b2"]],fqInv[F,fqInt[F,12]]];
   s=fqMul[F,fqNeg[F,c[[1]]],half];
   t=fqMul[F,fqNeg[F,fqAdd[F,fqMul[F,c[[1]],r],c[[3]]]],half];
   T={0,r,s,t};
   nc=fqTransform[F,c,T];
   <|"coeffs"->nc,"T"->T,"case"->"p > 3: genuine short model y^2 = x^3 + A x + B (A = -c4/48, B = -c6/864)","gamma"->None|>,
   ecFqNormalCore[F,c]]];

ECPNormalFormCharTwoThree[curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPNormalFormCharTwoThree[curve,fs[[1]]],ecFqNormalCmd[curve,fs]];

ecFqNormalCmd[curve_,fs_]:=Module[{prep,F,c,res},
  If[!ecFqCheckSpec[fs,ECPNormalFormCharTwoThree],Return[$Failed]];
  If[fs[[1]]!=2&&fs[[1]]!=3,Message[ECPNormalFormCharTwoThree::badChar,fs[[1]]];Return[$Failed]];
  prep=ecFqPrep[curve,fs,ECPNormalFormCharTwoThree];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  res=ecFqNormalCore[F,c];
  If[res===$Failed,Message[ECPNormalFormCharTwoThree::noSolve,fs];Return[$Failed]];
  <|"NormalForm"->ecFqOutList[F,res["coeffs"]],"Transformation"->ecFqOutList[F,res["T"]],
    "Case"->res["case"],"Characteristic"->fs[[1]],"FieldOrder"->F["q"],
    "Gamma"->If[res["gamma"]===None,Missing["NotApplicable"],ecFqOut[F,res["gamma"]]]|>];

fqEquation[co_List]:=With[{xs=Symbol["x"],ys=Symbol["y"]},
  ys^2+co[[1]]*xs*ys+co[[3]]*ys==xs^3+co[[2]]*xs^2+co[[4]]*xs+co[[5]]];

ECPToShortWeierstrassFp[curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPToShortWeierstrassFp[curve,fs[[1]]],ecFqShortCmd[curve,fs]];

ecFqShortCmd[curve_,fs_]:=Module[{prep,F,c,res,nc,pure,co},
  prep=ecFqPrep[curve,fs,ECPToShortWeierstrassFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  res=ecFqShortCore[F,c];
  If[res===$Failed,Message[ECPNormalFormCharTwoThree::noSolve,fs];Return[$Failed]];
  nc=res["coeffs"];
  pure=(nc[[1]]<0&&nc[[2]]<0&&nc[[3]]<0);
  co=ecFqOutList[F,nc];
  <|"Characteristic"->fs[[1]],"FieldOrder"->F["q"],"OriginalCoefficients"->ecFqOutList[F,c],
    "ShortCoefficients"->co,"Transformation"->ecFqOutList[F,res["T"]],"Case"->res["case"],
    "PureShortQ"->pure,"ShortPair"->If[pure,{co[[4]],co[[5]]},Missing["NotAvailable"]],
    "Equation"->fqEquation[co],"Discriminant"->ecFqOut[F,fqInvariants[F,nc]["D"]],
    "jInvariant"->ecFqOut[F,fqJ[F,nc]]|>];

ECPToShortCoordinatesFp[pt_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPToShortCoordinatesFp[pt,curve,fs[[1]]],ecFqToShortPt[pt,curve,fs]];

ecFqToShortPt[pt_,curve_,fs_]:=Module[{prep,F,c,res,Q,u,r,s,t,x,y,ui},
  prep=ecFqPrep[curve,fs,ECPToShortCoordinatesFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  res=ecFqShortCore[F,c];
  If[res===$Failed,Message[ECPNormalFormCharTwoThree::noSolve,fs];Return[$Failed]];
  Q=ecFqPoint[pt,F,c,ECPToShortCoordinatesFp];If[Q===$Failed,Return[$Failed]];
  If[Q===Infinity,Return[Infinity]];
  {u,r,s,t}=res["T"];{x,y}=Q;ui=fqInv[F,u];
  ecFqOutPt[F,{fqMul[F,fqSub[F,x,r],fqPow[F,ui,2]],
    fqMul[F,fqSub[F,fqSub[F,y,fqMul[F,s,fqSub[F,x,r]]],t],fqPow[F,ui,3]]}]];

ECPFromShortCoordinatesFp[pt_,curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPFromShortCoordinatesFp[pt,curve,fs[[1]]],ecFqFromShortPt[pt,curve,fs]];

ecFqFromShortPt[pt_,curve_,fs_]:=Module[{prep,F,c,res,Q,u,r,s,t,X,Y,nc},
  prep=ecFqPrep[curve,fs,ECPFromShortCoordinatesFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  res=ecFqShortCore[F,c];
  If[res===$Failed,Message[ECPNormalFormCharTwoThree::noSolve,fs];Return[$Failed]];
  nc=res["coeffs"];
  Q=ecFqPoint[pt,F,nc,ECPFromShortCoordinatesFp];If[Q===$Failed,Return[$Failed]];
  If[Q===Infinity,Return[Infinity]];
  {u,r,s,t}=res["T"];{X,Y}=Q;
  ecFqOutPt[F,{fqAdd[F,fqMul[F,fqPow[F,u,2],X],r],
    fqSum[F,{fqMul[F,fqPow[F,u,3],Y],fqProd[F,{fqPow[F,u,2],s,X}],t}]}]];

ECPJInvariant[curve_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPJInvariant[curve,fs[[1]]],ecFqJCmd[curve,fs]];

ecFqJCmd[curve_,fs_]:=Module[{prep,F,c},
  prep=ecFqPrep[curve,fs,ECPJInvariant];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  ecFqOut[F,fqJ[F,c]]];

fqKey[{i_,j_,k_}]:=i+4*j+16*k;
fqUnitKeys={1,4,16};

fqPolyAdd[F_,A_Association,B_Association]:=Module[{res=A,key,n},
  Do[n=fqAdd[F,Lookup[res,key,-1],B[key]];
   If[n<0,res=KeyDrop[res,key],res[key]=n],{key,Keys[B]}];
  res];

fqPolyMul[F_,A_Association,B_Association]:=Module[{res=<||>,k1,k2,key,n},
  Do[key=k1+k2;
   n=fqAdd[F,Lookup[res,key,-1],fqMul[F,A[k1],B[k2]]];
   If[n<0,res=KeyDrop[res,key],res[key]=n],
   {k1,Keys[A]},{k2,Keys[B]}];
  res];

fqPolyPow[F_,A_Association,n_Integer]:=Module[{res=<|0->0|>,i},
  Do[res=fqPolyMul[F,res,A],{i,n}];res];

fqPolyEval[F_,terms_List,P_List]:=fqSum[F,
  Function[tm,fqMul[F,tm[[2]],fqProd[F,MapThread[fqPow[F,#1,#2]&,{P,tm[[1]]}]]]]/@terms];

fqPolyPartial[F_,terms_List,P_List,var_Integer]:=fqSum[F,
  Function[tm,If[tm[[1,var]]==0,-1,
    fqMul[F,fqScale[F,tm[[1,var]],tm[[2]]],
     fqProd[F,MapThread[fqPow[F,#1,#2]&,{P,ReplacePart[tm[[1]],var->tm[[1,var]]-1]}]]]]]/@terms];

fqProjEqualQ[F_,U_List,V_List]:=AllTrue[{{1,2},{2,3},{1,3}},
  fqSub[F,fqMul[F,U[[#[[1]]]],V[[#[[2]]]]],fqMul[F,U[[#[[2]]]],V[[#[[1]]]]]]<0&];

fqSubstitute[F_,terms_List,M_List]:=Module[{Ls,pw,H=<||>,tm,t,j,n},
  Ls=Table[
    Association[Table[If[M[[i,j]]>=0,fqUnitKeys[[j]]->M[[i,j]],Nothing],{j,3}]],{i,3}];
  pw=Table[Table[fqPolyPow[F,Ls[[i]],n],{n,0,3}],{i,3}];
  Do[t=<|0->tm[[2]]|>;
   Do[t=fqPolyMul[F,t,pw[[j,tm[[1,j]]+1]]],{j,3}];
   H=fqPolyAdd[F,H,t],
   {tm,terms}];
  H];

ECPCubicToWeierstrassCharTwoThree[P_List,Fexpr_,fs:{_Integer,_Integer}]:=
  If[fs[[2]]==1&&PrimeQ[fs[[1]]],ECPCubicToWeierstrassCharTwoThree[P,Fexpr,fs[[1]]],ecFqCubicCmd[Fexpr,P,fs]];

(* FIX: documented argument order (F, P, p) *)
ECPCubicToWeierstrassCharTwoThree[Fexpr:Except[_List],P_List,p:(_Integer|{_Integer,_Integer})]:=
  ECPCubicToWeierstrassCharTwoThree[P,Fexpr,p];

ecFqCubicCmd[Fexpr_,P_List,fs_]:=Module[
  {F,vars,cand,expr,rules,terms,Pc,g3,gA,gB,gC,Q,R,Mx,H,i,
   lam,mu,kinv,H2,a,b,co,cc,tmp,named,Mt,i1,j1},
  If[!ecFqCheckSpec[fs,ECPCubicToWeierstrassCharTwoThree],Return[$Failed]];
  If[fs[[1]]!=2&&fs[[1]]!=3,Message[ECPCubicToWeierstrassCharTwoThree::badChar,fs[[1]]];Return[$Failed]];
  F=ecFqSpec[fs,ECPCubicToWeierstrassCharTwoThree];
  If[F===$Failed,Return[$Failed]];
  If[Length[P]!=3,Message[ECPCubicToWeierstrassCharTwoThree::badPoint,P];Return[$Failed]];
  expr=Expand[Fexpr];
  cand=Variables[expr];
  named=Select[cand,namedQ[#,{"x","y","z","X","Y","Z"}]&];
  vars=If[Length[named]==3,named,cand];
  If[Length[vars]!=3,Message[ECPCubicToWeierstrassCharTwoThree::badVars,cand];Return[$Failed]];
  vars=SortBy[vars,ToLowerCase[SymbolName[#]]&];
  If[!PolynomialQ[expr,vars],Message[ECPCubicToWeierstrassCharTwoThree::notPoly,Fexpr];Return[$Failed]];
  rules=CoefficientRules[expr,vars];
  terms=Table[{rules[[i,1]],ecFqParse[F,rules[[i,2]]]},{i,Length[rules]}];
  If[MemberQ[terms[[All,2]],$Failed],
   ecMsg[ECPCubicToWeierstrassCharTwoThree,"badelem",Pick[rules[[All,2]],terms[[All,2]],$Failed],F["q"]];Return[$Failed]];
  If[!AllTrue[terms[[All,1]],Total[#]==3&],Message[ECPCubicToWeierstrassCharTwoThree::notCubic,Fexpr];Return[$Failed]];
  Pc=ecFqParse[F,#]&/@P;
  If[MemberQ[Pc,$Failed],ecMsg[ECPCubicToWeierstrassCharTwoThree,"badelem",P,F["q"]];Return[$Failed]];
  If[AllTrue[Pc,#<0&],Message[ECPCubicToWeierstrassCharTwoThree::badPoint,P];Return[$Failed]];
  If[fqPolyEval[F,terms,Pc]>=0,
   Message[ECPCubicToWeierstrassCharTwoThree::notOnCurve,ecFqOutList[F,Pc],F["q"]];Return[$Failed]];
  g3=Table[fqPolyPartial[F,terms,Pc,i],{i,3}];
  If[AllTrue[g3,#<0&],
   Message[ECPCubicToWeierstrassCharTwoThree::singularPoint,ecFqOutList[F,Pc],F["q"]];Return[$Failed]];
  {gA,gB,gC}=g3;

  Q=SelectFirst[{{fqNeg[F,gB],gA,-1},{fqNeg[F,gC],-1,gA},{-1,fqNeg[F,gC],gB}},
    !AllTrue[#,Function[e,e<0]]&&!fqProjEqualQ[F,#,Pc]&];
  If[Q===Missing["NotFound"],Message[ECPCubicToWeierstrassCharTwoThree::noAuxPoint,F["q"]];Return[$Failed]];

  i=SelectFirst[{1,2,3},g3[[#]]>=0&];
  R=ReplacePart[{-1,-1,-1},i->0];
  Mx=Table[{Q[[k]],Pc[[k]],R[[k]]},{k,3}];
  H=fqSubstitute[F,terms,Mx];
  If[AnyTrue[{{2,1,0},{1,2,0},{0,3,0}},Lookup[H,fqKey[#],-1]>=0&],
   Message[ECPCubicToWeierstrassCharTwoThree::notFlex,ecFqOutList[F,Pc],F["q"]];Return[$Failed]];
  a=Lookup[H,fqKey[{3,0,0}],-1];
  b=Lookup[H,fqKey[{0,2,1}],-1];
  If[a<0||b<0,Message[ECPCubicToWeierstrassCharTwoThree::notFlex,ecFqOutList[F,Pc],F["q"]];Return[$Failed]];

  tmp=fqMul[F,b,fqInv[F,a]];
  lam=fqNeg[F,tmp];mu=tmp;
  kinv=fqInv[F,fqMul[F,b,fqMul[F,mu,mu]]];
  H2=Association[KeyValueMap[
    Function[{key,v},key->fqProd[F,{v,fqPow[F,lam,Mod[key,4]],fqPow[F,mu,Mod[Quotient[key,4],4]],kinv}]],H]];
  cc[{i1_,j1_,k1_}]:=Lookup[H2,fqKey[{i1,j1,k1}],-1];
  co={cc[{1,1,1}],fqNeg[F,cc[{2,0,1}]],cc[{0,1,2}],fqNeg[F,cc[{1,0,2}]],fqNeg[F,cc[{0,0,3}]]};
  Mt=Table[fqMul[F,Mx[[i1,j1]],{lam,mu,0}[[j1]]],{i1,3},{j1,3}];
  <|"WeierstrassCoefficients"->ecFqOutList[F,co],
    "Transformation"->Map[ecFqOutList[F,#]&,Mt],
    "Scaling"-><|"X"->ecFqOut[F,lam],"Y"->ecFqOut[F,mu]|>,
    "AuxiliaryPoints"-><|"Q"->ecFqOutList[F,Q],"P"->ecFqOutList[F,Pc],"R"->ecFqOutList[F,R]|>,
    "Characteristic"->fs[[1]],"FieldOrder"->F["q"]|>];

ecFqExt[fs_,f_]:=If[!ecFqCheckSpec[fs,f],$Failed,
  If[fs[[2]]<2,(ecMsg[f,"extOnly",fs];$Failed),ecFqSpec[fs,f]]];

ECPFiniteFieldInfo[fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFiniteFieldInfo],xs=Symbol["x"]},
  If[F===$Failed,Return[$Failed]];
  <|"p"->F["p"],"r"->F["r"],"q"->F["q"],
    "FieldPolynomial"->xs^F["r"]+Sum[F["poly"][[i+1]]*xs^i,{i,0,F["r"]-1}],
    "Generator"->"g, the class of x modulo FieldPolynomial; g is a primitive element (it generates F_q^*)",
    "Elements"->"0 and g^k for k = 0..q-2 (g^0 prints as 1)"|>];

ECPFqAdd[a_,b_,fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFqAdd],x,y},
  If[F===$Failed,Return[$Failed]];
  x=ecFqParse[F,a];y=ecFqParse[F,b];
  If[x===$Failed||y===$Failed||!ecFqOneSymbolQ[{a,b}],ecMsg[ECPFqAdd,"badelem",{a,b},F["q"]];Return[$Failed]];
  ecFqOut[F,fqAdd[F,x,y]]];

ECPFqMultiply[a_,b_,fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFqMultiply],x,y},
  If[F===$Failed,Return[$Failed]];
  x=ecFqParse[F,a];y=ecFqParse[F,b];
  If[x===$Failed||y===$Failed||!ecFqOneSymbolQ[{a,b}],ecMsg[ECPFqMultiply,"badelem",{a,b},F["q"]];Return[$Failed]];
  ecFqOut[F,fqMul[F,x,y]]];

ECPFqInverse[a_,fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFqInverse],x},
  If[F===$Failed,Return[$Failed]];
  x=ecFqParse[F,a];
  If[x===$Failed,ecMsg[ECPFqInverse,"badelem",{a},F["q"]];Return[$Failed]];
  If[x<0,ecMsg[ECPFqInverse,"zeroInverse"];Return[$Failed]];
  ecFqOut[F,fqInv[F,x]]];

ECPFqVector[a_,fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFqVector],x},
  If[F===$Failed,Return[$Failed]];
  x=ecFqParse[F,a];
  If[x===$Failed,ecMsg[ECPFqVector,"badelem",{a},F["q"]];Return[$Failed]];
  If[x<0,ConstantArray[0,F["r"]],Reverse[IntegerDigits[F["exp"][[x+1]],F["p"],F["r"]]]]];

ECPFqElement[v_List,fs:{_Integer,_Integer}]:=Module[{F=ecFqExt[fs,ECPFqElement],e},
  If[F===$Failed,Return[$Failed]];
  If[!(Length[v]==F["r"]&&AllTrue[v,IntegerQ]),ecMsg[ECPFqElement,"badvector",v,F["r"]];Return[$Failed]];
  e=FromDigits[Reverse[Mod[v,F["p"]]],F["p"]];
  ecFqOut[F,F["log"][[e+1]]]];

(* 19. GROUP OF POINTS OVER F_q *)

ecFqOutEl[F_,a_]:=If[F["r"]==1,If[a<0,0,F["exp"][[a+1]]],ecFqOut[F,a]];
ecFqOutElPt[F_,P_]:=If[P===Infinity,Infinity,ecFqOutEl[F,#]&/@P];

ecFqEnumPoints[F_,{a1_,a2_,a3_,a4_,a6_}]:=Module[{els,sq,tt,res,L,f0,ys,x},
  els=Prepend[Range[0,F["m"]-1],-1];
  sq=GroupBy[els,fqMul[F,#,#]&];
  tt=GroupBy[els,fqAdd[F,fqMul[F,#,#],#]&];
  res=Reap[Do[
     L=fqAdd[F,fqMul[F,a1,x],a3];
     f0=fqSum[F,{fqPow[F,x,3],fqProd[F,{a2,x,x}],fqMul[F,a4,x],a6}];
     ys=If[L<0,
       Lookup[sq,f0,{}],
       fqMul[F,L,#]&/@Lookup[tt,fqMul[F,f0,fqInv[F,fqMul[F,L,L]]],{}]];
     Scan[Sow[{x,#}]&,ys],
    {x,els}]][[2]];
  If[res==={},{},First[res]]];

ecFqPtOrder[F_,c_,nn_,P_]:=Module[{o=nn},
  Do[While[Mod[o,l]==0&&fqMulPt[F,c,o/l,P]===Infinity,o=o/l],{l,DeleteCases[First/@FactorInteger[nn],1]}];
  o];

ecFqStructure[F_,c_,pts_,nn_]:=Module[{g,cand,n1=1,n2,P1,Q,H,pr},
  If[nn==1,Return[{1,1,{}}]];
  g=GCD[nn,F["q"]-1];
  cand=Select[Divisors[g],#>1&&Divisible[nn,#^2]&];
  Do[If[Length[Select[pts,fqMulPt[F,c,d,#]===Infinity&]]==d^2,n1=d;Break[]],{d,Reverse[cand]}];
  n2=nn/n1;
  P1=SelectFirst[Rest[pts],ecFqPtOrder[F,c,nn,#]==n2&];
  If[Head[P1]===Missing,Return[$Failed]];
  If[n1==1,Return[{n1,n2,{P1}}]];
  H=Association[(#->True)&/@NestList[fqAddPt[F,c,#,P1]&,Infinity,n2-1]];
  pr=DeleteCases[First/@FactorInteger[n1],1];
  Q=SelectFirst[Rest[pts],
    Function[R,KeyExistsQ[H,fqMulPt[F,c,n1,R]]&&AllTrue[pr,!KeyExistsQ[H,fqMulPt[F,c,n1/#,R]]&]]];
  If[Head[Q]===Missing,Return[$Failed]];
  {n1,n2,{P1,Q}}];

ecFqStructStr[n1_,n2_]:=Which[n2==1,"trivial",n1==1,"Z/"<>ToString[n2],True,"Z/"<>ToString[n1]<>" x Z/"<>ToString[n2]];

ECPGroupFp[curve_,p_Integer]:=ECPGroupFp[curve,{p,1}];
ECPGroupFp[curve_,fs:{_Integer,_Integer}]:=Module[{prep,F,c,pts,nn,cnt,st},
  prep=ecFqPrep[curve,fs,ECPGroupFp];
  If[prep===$Failed,Return[$Failed]];
  {F,c}=prep;
  pts=Prepend[ecFqEnumPoints[F,c],Infinity];
  nn=Length[pts];
  cnt=ecFqGroupOrder[F,c,ECPGroupFp];
  If[cnt=!=nn,Message[ECPGroupFp::countMismatch,nn,cnt];Return[$Failed]];
  st=ecFqStructure[F,c,pts,nn];
  If[st===$Failed,Message[ECPGroupFp::structFail];Return[$Failed]];
  <|"Field"->fs,
    "Curve"->(ecFqOutEl[F,#]&/@c),
    "Order"->nn,
    "Invariants"->st[[{1,2}]],
    "Structure"->ecFqStructStr[st[[1]],st[[2]]],
    "Generators"->(ecFqOutElPt[F,#]&/@st[[3]]),
    "Points"->(ecFqOutElPt[F,#]&/@pts)|>];

(* 20. BACHET DUPLICATION *)

ecBachetX[x_,{a1_,a2_,a3_,a4_,a6_}]:=Module[{b2,b4,b6,b8,den},
  b2=a1^2+4*a2;
  b4=2*a4+a1*a3;
  b6=a3^2+4*a6;
  b8=a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2-a4^2;
  den=4*x^3+b2*x^2+2*b4*x+b6;
  If[ecZeroQ[den],Infinity,Together[(x^4-b4*x^2-2*b6*x-b8)/den]]];

ECPBachetDuplication[Infinity,curve_]:=If[ecLong[curve,ECPBachetDuplication]===$Failed,$Failed,Infinity];

ECPBachetDuplication[{x_,y_},curve_]:=Module[{c,a1,a2,a3,a4,a6,den,lam,nu,x3},
  If[!(ecScalarQ[x]&&ecScalarQ[y]),ecMsg[ECPBachetDuplication,"badpoint",{x,y}];Return[$Failed]];
  c=ecLong[curve,ECPBachetDuplication];
  If[c===$Failed,Return[$Failed]];
  If[!ecCheckOnLong[{x,y},c,ECPBachetDuplication],Return[$Failed]];
  {a1,a2,a3,a4,a6}=c;
  den=2*y+a1*x+a3;
  If[ecZeroQ[den],Return[Infinity]];
  x3=ecBachetX[x,c];
  lam=(3*x^2+2*a2*x+a4-a1*y)/den;
  nu=y-lam*x;
  {x3,Simplify[-(lam+a1)*x3-nu-a3]}];

ECPBachetDuplication[x_,curve_]/;ecScalarQ[x]:=Module[{c},
  c=ecLong[curve,ECPBachetDuplication];
  If[c===$Failed,Return[$Failed]];
  ecBachetX[x,c]];

(* 21. MILLER'S ALGORITHM AND THE WEIL PAIRING OVER F_q (NEW IN v18) *)
(* All arithmetic uses the discrete-log field tables of section 18 (elements are log codes, -1 = 0), for every
   q = p^r including r = 1 and p = 2, 3. Points are {x,y} of codes or Infinity; the user sees ordinary notation
   (integers for r = 1, powers of g for r >= 2). *)

ecPairCtx[F_,c_]:=<|"F"->F,"c"->c,
  "add"->Function[{a,b},fqAdd[F,a,b]],"sub"->Function[{a,b},fqSub[F,a,b]],
  "mul"->Function[{a,b},fqMul[F,a,b]],"inv"->Function[a,fqInv[F,a]],"neg"->Function[a,fqNeg[F,a]],
  "int"->Function[k,fqInt[F,k]],"zero"->-1,"one"->0,
  "padd"->Function[{A,B},fqAddPt[F,c,A,B]],"pmul"->Function[{k,P},fqMulPt[F,c,k,P]]|>;

(* One Miller step: the chord through T and R (the tangent if T = R) evaluated at Q = {xq,yq}.
   Returns {S, num, den}: S = T + R, num = value of the chord at Q, den = value at Q of the vertical line through S
   (den = 1 when T + R = O, in which case the chord itself is the vertical line x - x(T)). *)
ecMillerStep[o_,T_,R_,Q_]:=Module[
 {ad=o["add"],sb=o["sub"],ml=o["mul"],iv=o["inv"],ng=o["neg"],it=o["int"],
  a1,a2,a3,a4,a6,x1,y1,x2,y2,xq,yq,lam,nu,x3,y3,den},
 If[T===Infinity,Return[{R,o["one"],o["one"]}]];
 {a1,a2,a3,a4,a6}=o["c"];
 {x1,y1}=T;{x2,y2}=R;{xq,yq}=Q;
 If[x1===x2,
  If[ad[ad[y1,y2],ad[ml[a1,x2],a3]]===o["zero"],
   Return[{Infinity,sb[xq,x1],o["one"]}]];
  den=ad[ad[ml[it[2],y1],ml[a1,x1]],a3];
  lam=ml[sb[ad[ad[ml[it[3],ml[x1,x1]],ml[it[2],ml[a2,x1]]],a4],ml[a1,y1]],iv[den]],
  lam=ml[sb[y2,y1],iv[sb[x2,x1]]]];
 nu=sb[y1,ml[lam,x1]];
 x3=sb[sb[sb[ad[ml[lam,lam],ml[a1,lam]],a2],x1],x2];
 y3=sb[ng[ml[ad[lam,a1],x3]],ad[nu,a3]];
 {{x3,y3},sb[sb[yq,y1],ml[lam,sb[xq,x1]]],sb[xq,x3]}];

(* Miller's double-and-add loop: f_{n,P}(Q), where div f = n(P) - ([n]P) - (n-1)(O).
   Returns $Failed if Q hits a zero or a pole of an intermediate function. *)
ecMillerCore[o_,n_Integer,P_,Q_]:=Module[{f=o["one"],T=P,r,S,num,den,zero=o["zero"],ml=o["mul"],iv=o["inv"]},
 Catch[
  Do[
   r=ecMillerStep[o,T,T,Q];S=r[[1]];num=r[[2]];den=r[[3]];
   If[num===zero||den===zero,Throw[$Failed]];
   f=ml[ml[f,f],ml[num,iv[den]]];
   T=S;
   If[bit==1,
    If[T===Infinity,Throw[$Failed]];
    r=ecMillerStep[o,T,P,Q];S=r[[1]];num=r[[2]];den=r[[3]];
    If[num===zero||den===zero,Throw[$Failed]];
    f=ml[f,ml[num,iv[den]]];
    T=S],
   {bit,Rest[IntegerDigits[n,2]]}];
  f]];

ecInCyclicQ[o_,n_Integer,P_,Q_]:=Module[{R=Infinity,found=False,pa=o["padd"]},
 Do[R=pa[R,P];If[R===Q,found=True;Break[]],{n}];
 found];

(* Weil pairing e_n(P,Q) = (-1)^n f_{n,P}(Q) / f_{n,Q}(P) for P, Q in E[n].
   If P has exact order m < n then e_n(P,Q) = e_m(P,(n/m)Q) (and symmetrically for Q), so the formula is only
   applied to points of exact order n. A zero in either Miller value occurs exactly when P and Q are dependent
   (one lies in the cyclic group of the other); the pairing is then 1. *)
ecWeilCore[o_,n_Integer,P_,Q_]:=Module[{pm=o["pmul"],divs,mP,mQ,a,b,v},
 If[P===Infinity||Q===Infinity,Return[o["one"]]];
 divs=Divisors[n];
 mP=SelectFirst[divs,pm[#,P]===Infinity&];
 If[mP<n,Return[ecWeilCore[o,mP,P,pm[n/mP,Q]]]];
 mQ=SelectFirst[divs,pm[#,Q]===Infinity&];
 If[mQ<n,Return[ecWeilCore[o,mQ,pm[n/mQ,P],Q]]];
 If[P===Q,Return[o["one"]]];
 a=ecMillerCore[o,n,P,Q];
 b=ecMillerCore[o,n,Q,P];
 If[a===$Failed||b===$Failed,
  Return[If[ecInCyclicQ[o,n,P,Q]||ecInCyclicQ[o,n,Q,P],o["one"],$Failed]]];
 v=o["mul"][a,o["inv"][b]];
 If[OddQ[n],o["neg"][v],v]];

(* Reads curve, field and the two points once. Returns an Association or $Failed (a message has been issued). *)
ecPairPrep[P_,Q_,curve_,field_,f_]:=Module[{fs=If[IntegerQ[field],{field,1},field],prep,F,c,P1,Q1},
 prep=ecFqPrep[curve,fs,f];
 If[prep===$Failed,Return[$Failed]];
 {F,c}=prep;
 P1=ecFqPoint[P,F,c,f];If[P1===$Failed,Return[$Failed]];
 Q1=ecFqPoint[Q,F,c,f];If[Q1===$Failed,Return[$Failed]];
 <|"o"->ecPairCtx[F,c],"F"->F,"P"->P1,"Q"->Q1|>];

ECPMillerFp[n_Integer,P_,Q_,curve_,field:(_Integer|{_Integer,_Integer})]:=Module[{prep,v,fs=If[IntegerQ[field],{field,1},field]},
 If[n<1,ecMsg[ECPMillerFp,"badn",n];Return[$Failed]];
 prep=ecPairPrep[P,Q,curve,fs,ECPMillerFp];
 If[prep===$Failed,Return[$Failed]];
 If[prep["Q"]===Infinity,ecMsg[ECPMillerFp,"atInfinity"];Return[$Failed]];
 If[prep["P"]===Infinity,Return[ecFqOutEl[prep["F"],0]]];
 v=ecMillerCore[prep["o"],n,prep["P"],prep["Q"]];
 If[v===$Failed,ecMsg[ECPMillerFp,"failed"];Return[$Failed]];
 ecFqOutEl[prep["F"],v]];

ECPWeilPairingFp[n_Integer,P_,Q_,curve_,field:(_Integer|{_Integer,_Integer})]:=Module[{prep,o,pm,v,fs=If[IntegerQ[field],{field,1},field]},
 If[n<1,ecMsg[ECPWeilPairingFp,"badn",n];Return[$Failed]];
 If[!ecFqCheckSpec[fs,ECPWeilPairingFp],Return[$Failed]];
 If[GCD[n,fs[[1]]]!=1,ecMsg[ECPWeilPairingFp,"notcoprime",n,fs[[1]]];Return[$Failed]];
 prep=ecPairPrep[P,Q,curve,fs,ECPWeilPairingFp];
 If[prep===$Failed,Return[$Failed]];
 o=prep["o"];pm=o["pmul"];
 If[pm[n,prep["P"]]=!=Infinity,ecMsg[ECPWeilPairingFp,"nottorsion",P,n];Return[$Failed]];
 If[pm[n,prep["Q"]]=!=Infinity,ecMsg[ECPWeilPairingFp,"nottorsion",Q,n];Return[$Failed]];
 v=ecWeilCore[o,n,prep["P"],prep["Q"]];
 If[v===$Failed,ecMsg[ECPWeilPairingFp,"failed"];Return[$Failed]];
 ecFqOutEl[prep["F"],v]];

(* A basis {P,Q} of E[n] inside E(F_q): P of exact order n and e_n(P,Q) a primitive n-th root of unity,
   which forces <P,Q> = E[n]. Requires E[n] contained in E(F_q), i.e. Z/n x Z/n is a subgroup. *)
ECPTorsionBasisFp[n_Integer,curve_,field:(_Integer|{_Integer,_Integer})]:=Module[
 {fs=If[IntegerQ[field],{field,1},field],prep,F,c,o,pm,pts,tors,primes,exactQ,P0,Q0,m},
 If[n<2,ecMsg[ECPTorsionBasisFp,"badn",n];Return[$Failed]];
 prep=ecFqPrep[curve,fs,ECPTorsionBasisFp];
 If[prep===$Failed,Return[$Failed]];
 {F,c}=prep;
 If[GCD[n,F["p"]]!=1,ecMsg[ECPTorsionBasisFp,"notcoprime",n,F["p"]];Return[$Failed]];
 o=ecPairCtx[F,c];pm=o["pmul"];m=F["m"];
 pts=ecFqEnumPoints[F,c];
 tors=Select[pts,pm[n,#]===Infinity&];
 If[Length[tors]!=n^2-1,ecMsg[ECPTorsionBasisFp,"notfull",n,fs];Return[$Failed]];
 primes=First/@FactorInteger[n];
 exactQ[pt_]:=AllTrue[primes,pm[n/#,pt]=!=Infinity&];
 P0=SelectFirst[tors,exactQ];
 If[Head[P0]===Missing,ecMsg[ECPTorsionBasisFp,"nobasis",n,fs];Return[$Failed]];
 Q0=SelectFirst[tors,Function[cand,
    With[{z=ecWeilCore[o,n,P0,cand]},z=!=$Failed&&z>=0&&m/GCD[z,m]==n]]];
 If[Head[Q0]===Missing,ecMsg[ECPTorsionBasisFp,"nobasis",n,fs];Return[$Failed]];
 {ecFqOutElPt[F,P0],ecFqOutElPt[F,Q0]}];

(* Reduced Tate pairing t_n(P,Q) = f_{n,P}(Q)^((q-1)/n), P in E(F_q)[n], n | q-1, Q in E(F_q) (defined modulo nE(F_q)).
   P of exact order m < n is reduced to t_m(P,Q) (f_{n,P} = f_{m,P}^(n/m)). If Q is a zero or pole of an intermediate Miller
   function, the pairing is computed as f_{n,P}(Q+S)/f_{n,P}(S) for a point S of E(F_q) for which both values are defined. *)
ecTateCore[o_,n_Integer,P_,Q_]:=Module[{F=o["F"],pm=o["pmul"],pa=o["padd"],m,e,f,a,b,res=$Failed,S,QS},
 If[P===Infinity||Q===Infinity,Return[o["one"]]];
 m=SelectFirst[Divisors[n],pm[#,P]===Infinity&];
 e=(F["q"]-1)/m;
 f=ecMillerCore[o,m,P,Q];
 If[f=!=$Failed&&f=!=o["zero"],Return[fqPow[F,f,e]]];
 Do[
  QS=pa[Q,S];
  If[QS=!=Infinity,
   a=ecMillerCore[o,m,P,QS];b=ecMillerCore[o,m,P,S];
   If[a=!=$Failed&&b=!=$Failed&&a=!=o["zero"]&&b=!=o["zero"],
    res=fqPow[F,o["mul"][a,o["inv"][b]],e];Break[]]],
  {S,ecFqEnumPoints[F,o["c"]]}];
 res];

ECPTatePairingFp[n_Integer,P_,Q_,curve_,field:(_Integer|{_Integer,_Integer})]:=Module[{prep,o,pm,v,fs=If[IntegerQ[field],{field,1},field]},
 If[n<1,ecMsg[ECPTatePairingFp,"badn",n];Return[$Failed]];
 prep=ecPairPrep[P,Q,curve,fs,ECPTatePairingFp];
 If[prep===$Failed,Return[$Failed]];
 If[!Divisible[prep["F"]["q"]-1,n],ecMsg[ECPTatePairingFp,"notdivq",n,prep["F"]["q"]];Return[$Failed]];
 o=prep["o"];pm=o["pmul"];
 If[pm[n,prep["P"]]=!=Infinity,ecMsg[ECPTatePairingFp,"nottorsion",P,n];Return[$Failed]];
 v=ecTateCore[o,n,prep["P"],prep["Q"]];
 If[v===$Failed,ecMsg[ECPTatePairingFp,"failed"];Return[$Failed]];
 ecFqOutEl[prep["F"],v]];

ecPairMessages={
 "badn"->"The torsion order n = `1` must be a positive integer (at least 2 for a basis).",
 "notcoprime"->"n = `1` must be prime to the characteristic p = `2`: the Weil pairing is defined on E[n] only when p does not divide n.",
 "nottorsion"->"The point `1` is not in E[`2`] (`2` times the point is not Infinity).",
 "atInfinity"->"The second point Q must not be Infinity: f_{n,P} has a pole at the point at infinity.",
 "failed"->"The Miller function (or the pairing) is undefined for these inputs: Q is a zero or pole of an intermediate function. For ECPMillerFp use a Q outside the subgroup generated by P; for ECPWeilPairingFp please report these inputs.",
 "notfull"->"E[`1`] is not contained in E(F_q) for the field `2`: the group does not contain Z/`1` x Z/`1`. Use an extension field {p, r} in which the full n-torsion is defined.",
 "nobasis"->"No basis of E[`1`] was found in E(F_q) for the field `2`.",
 "notdivq"->"The reduced Tate pairing needs n to divide q - 1 (n = `1`, q = `2`). Choose an extension field {p, r} with n | p^r - 1 (the embedding degree)."};
ecInstallMessages[{ECPMillerFp,ECPWeilPairingFp,ECPTorsionBasisFp,ECPTatePairingFp},ecPairMessages];
ecInstallMessages[{ECPMillerFp,ECPWeilPairingFp,ECPTorsionBasisFp,ECPTatePairingFp},ecFqMessages];
ecInstallMessages[{ECPMillerFp,ECPWeilPairingFp,ECPTorsionBasisFp,ECPTatePairingFp},ecFpMessages];

(* 22. SINGULAR FIBRES OF ELLIPTIC FAMILIES OVER Q(t) (NEW IN v20; ECPSchoofPointCount is new in v21) *)
(* Kodaira's table in characteristic 0 reads the fibre type off the orders of vanishing of c4, c6 and Delta, provided the
   model is minimal at the point. The order along an irreducible polynomial p(t) is computed by repeated exact division,
   so no algebraic numbers are needed even when p has degree > 1. The fibre at t = Infinity uses s = 1/t and the weights
   s^(4n) c4, s^(6n) c6, s^(12n) Delta. *)

ecfDeg[e_,t_]:=If[PossibleZeroQ[e],0,Exponent[e,t]];

ecfSquareQ[c_]:=If[MatchQ[c,_Integer|_Rational],
  c>=0&&IntegerQ[Sqrt[Numerator[c]]]&&IntegerQ[Sqrt[Denominator[c]]],
  Missing["Symbolic"]];

ecfValPoly[q_,p_,t_]:=Module[{r=q,k=0,qr},
  If[PossibleZeroQ[r],Return[Infinity]];
  While[True,
   qr=PolynomialQuotientRemainder[r,p,t];
   If[PossibleZeroQ[qr[[2]]],r=Expand[qr[[1]]];k++,Break[]]];
  k];

ecfValP[e_,p_,t_]:=Module[{nd,vn,vd},
  If[PossibleZeroQ[e],Return[Infinity]];
  nd=NumeratorDenominator[Together[e]];
  vn=ecfValPoly[nd[[1]],p,t];
  vd=ecfValPoly[nd[[2]],p,t];
  vn-vd];

(* leading coefficient of e in the local parameter t - t0 *)
ecfLead[e_,t_,t0_]:=Module[{q,nu,de,kn,kd},
  q=Together[e/.t->t+t0];
  nu=Expand[Numerator[q]];de=Expand[Denominator[q]];
  kn=Exponent[nu,t,Min];kd=Exponent[de,t,Min];
  Coefficient[nu,t,kn]/Coefficient[de,t,kd]];

ecfKodaira[{of_,og_,od_}]:=Which[
  od===0,{"I0",0},
  of>=4&&og>=6,{"non-minimal",Indeterminate},
  of==0||og==0,{"I"<>ToString[od],od},
  og==1,{"II",2},
  of==1,{"III",3},
  og==2,{"IV",4},
  od==6,{"I0*",6},
  of==2&&og==3&&od>6,{"I"<>ToString[od-6]<>"*",od},
  of>=3&&og==4,{"IV*",8},
  of==3&&og>=5,{"III*",9},
  of>=4&&og==5,{"II*",10},
  True,{"unclassified",Indeterminate}];

ecfScaling[type_,od_]:=If[MemberQ[{"II","III","IV","I0*","IV*","III*","II*"},type],12/(12-od),Missing["NotApplicable"]];

ecfGauge[type_,split_]:=Module[{n},
  Which[
   MemberQ[{"I0","I1","II"},type],"none",
   type==="I2"||type==="III","su(2)",
   type==="IV",Which[split===True,"su(3)",split===False,"su(2)",True,"su(3) or su(2)"],
   type==="I0*","so(8), so(7) or g2 (depends on the monodromy cover)",
   (* FIX: was StringMatchQ[type,"I"~~DigitCharacter..~~"*"], in which "*" is a wildcard, so "I3" matched
      this branch and gave "so(8 + 2 Null)" *)
   StringMatchQ[type,RegularExpression["I\\d+\\*"]],
    n=ToExpression[StringTake[type,{2,-2}]];
    Which[split===True,"so("<>ToString[2 n+8]<>")",split===False,"so("<>ToString[2 n+7]<>")",
     True,"so("<>ToString[2 n+8]<>") or so("<>ToString[2 n+7]<>")"],
   StringMatchQ[type,"I"~~DigitCharacter..],
    n=ToExpression[StringDrop[type,1]];
    Which[split===True,"su("<>ToString[n]<>")",split===False,"sp("<>ToString[Floor[n/2]]<>")",
     True,"su("<>ToString[n]<>") or sp("<>ToString[Floor[n/2]]<>")"],
   type==="IV*",Which[split===True,"e6",split===False,"f4",True,"e6 or f4"],
   type==="III*","e7",
   type==="II*","e8",
   True,"unknown"]];

(* split data for the types where it is decided by one leading coefficient: I_n (n >= 1) and IV *)
ecfSplitFor[type_,c6_,t_,t0_]:=Module[{crit},
  Which[
   StringMatchQ[type,"I"~~DigitCharacter..]&&type=!="I0",
    crit=-ecfLead[c6,t,t0];{ecfSquareQ[crit],crit},
   type==="IV",
    crit=ecfLead[-c6/864,t,t0];{ecfSquareQ[crit],crit},
   True,{Missing["NotApplicable"],Missing["NotApplicable"]}]];

ecfRecord[loc_,deg_,ords_,split_,crit_]:=Module[{k=ecfKodaira[ords]},
  If[k[[1]]==="non-minimal",Message[ECPFibreList::nonminimal,loc]];
  <|"Location"->loc,"Degree"->deg,"Type"->k[[1]],"Euler"->k[[2]],"Orders"->ords,
    "Split"->split,"SplitCriterion"->crit,
    "GaugeAlgebra"->ecfGauge[k[[1]],split],
    "ScalingDimension"->ecfScaling[k[[1]],ords[[3]]]|>];

(* fibre along the irreducible polynomial p in the variable t; loc is what is reported as the location *)
ecfFibre[{c4_,c6_,Dl_},t_,p_,loc_]:=Module[{ords,k,sc,t0=None,lin=(Exponent[p,t]==1)},
  ords={ecfValP[c4,p,t],ecfValP[c6,p,t],ecfValP[Dl,p,t]};
  If[lin,t0=-Coefficient[p,t,0]/Coefficient[p,t,1]];
  k=ecfKodaira[ords];
  sc=If[lin,ecfSplitFor[k[[1]],c6,t,t0],{Missing["NeedsExtension"],Missing["NeedsExtension"]}];
  ecfRecord[loc,Exponent[p,t],ords,sc[[1]],sc[[2]]]];

ecfPrep[curve_,t_,f_]:=Module[{c,c4,c6,Dl},
  c=ecExtract[curve,f];
  If[c===$Failed,Return[$Failed]];
  c4=Expand[c4Of[c]];c6=Expand[c6Of[c]];Dl=Expand[ecDisc[c]];
  If[PossibleZeroQ[Dl],ecMsg[f,"isSingular",c];Return[$Failed]];
  If[!(PolynomialQ[c4,t]&&PolynomialQ[c6,t]&&PolynomialQ[Dl,t]),ecMsg[f,"notpoly",c,t];Return[$Failed]];
  {c4,c6,Dl}];

(* returns {n, record} or $Failed *)
ecfInf[{c4_,c6_,Dl_},t_,n_,f_]:=Module[{s,n0,c4i,c6i,Di},
  n0=If[n===Automatic,
    Max[1,Ceiling[ecfDeg[c4,t]/4],Ceiling[ecfDeg[c6,t]/6],Ceiling[ecfDeg[Dl,t]/12]],n];
  If[!(IntegerQ[n0]&&n0>=1),ecMsg[f,"badarg","n","a positive integer or Automatic",n];Return[$Failed]];
  c4i=Expand[Together[s^(4 n0) c4/.t->1/s]];
  c6i=Expand[Together[s^(6 n0) c6/.t->1/s]];
  Di=Expand[Together[s^(12 n0) Dl/.t->1/s]];
  If[!(PolynomialQ[c4i,s]&&PolynomialQ[c6i,s]&&PolynomialQ[Di,s]),ecMsg[f,"badn",n0];Return[$Failed]];
  {n0,ecfFibre[{c4i,c6i,Di},s,s,Infinity]}];

ECPKodairaType[ords:{_,_,_}]:=If[AllTrue[ords,(IntegerQ[#]&&#>=0)||#===Infinity&],
  ecfKodaira[ords],
  (ecMsg[ECPKodairaType,"badarg","orders","three non-negative integers (or Infinity)",ords];$Failed)];

ECPFibreAt[curve_,t_Symbol,t0_]:=Module[{inv},
  If[t0===Infinity,Return[ECPFibreAtInfinity[curve,t]]];
  If[!ecScalarQ[t0],ecMsg[ECPFibreAt,"badarg","point t0","a scalar or Infinity",t0];Return[$Failed]];
  inv=ecfPrep[curve,t,ECPFibreAt];
  If[inv===$Failed,Return[$Failed]];
  ecfFibre[inv,t,t-t0,t0]];

ECPFibreAtInfinity[curve_,t_Symbol,n_:Automatic]:=Module[{inv,r},
  inv=ecfPrep[curve,t,ECPFibreAtInfinity];
  If[inv===$Failed,Return[$Failed]];
  r=ecfInf[inv,t,n,ECPFibreAtInfinity];
  If[r===$Failed,$Failed,r[[2]]]];

ECPFibreList[curve_,t_Symbol,n_:Automatic]:=Module[{inv,Dl,inf,facs,fin,all,tot},
  inv=ecfPrep[curve,t,ECPFibreList];
  If[inv===$Failed,Return[$Failed]];
  Dl=inv[[3]];
  inf=ecfInf[inv,t,n,ECPFibreList];
  If[inf===$Failed,Return[$Failed]];
  facs=Select[FactorList[Dl],!FreeQ[#[[1]],t]&];
  fin=Map[Function[pm,
     ecfFibre[inv,t,pm[[1]],
      If[Exponent[pm[[1]],t]==1,-Coefficient[pm[[1]],t,0]/Coefficient[pm[[1]],t,1],pm[[1]]]]],facs];
  all=Append[fin,inf[[2]]];
  tot=If[AllTrue[all[[All,"Euler"]],IntegerQ],Total[(#["Degree"]*#["Euler"])&/@all],Indeterminate];
  <|"n"->inf[[1]],"Fibres"->all,"TotalEuler"->tot,"ExpectedEuler"->12 inf[[1]],
    "ConsistentQ"->TrueQ[tot===12 inf[[1]]]|>];

ECPJFunction[curve_]:=Module[{c,Dl},
  c=ecExtract[curve,ECPJFunction];
  If[c===$Failed,Return[$Failed]];
  Dl=Expand[ecDisc[c]];
  If[PossibleZeroQ[Dl],ecMsg[ECPJFunction,"isSingular",c];Return[$Failed]];
  Together[Expand[c4Of[c]]^3/Dl]];

ECPCoulombDimension[od_Integer]:=If[1<od<12,12/(12-od),
  (ecMsg[ECPCoulombDimension,"badarg","ordDelta","an integer with 1 < ordDelta < 12",od];$Failed)];

ECPGaugeAlgebra[type_String,split_:Automatic]:=ecfGauge[type,split];

ECPTateForm[ords_List,t_Symbol]:=If[Length[ords]==5&&AllTrue[ords,IntegerQ[#]&&#>=0&],
  Table[({1,1,3,5,7}[[i]]+(i+1) t) t^ords[[i]],{i,1,5}],
  (ecMsg[ECPTateForm,"badarg","orders","a list of five non-negative integers",ords];$Failed)];

ECPTorsionFamily[nn_Integer,d_Symbol]:=Module[{b,c},
  Which[
   nn==4,b=d;c=0,
   nn==5,b=d;c=d,
   nn==6,b=d+d^2;c=d,
   nn==7,b=d^3-d^2;c=d^2-d,
   True,Message[ECPTorsionFamily::badN,nn];Return[$Failed]];
  <|"Coefficients"->{1-c,-b,-b,0,0},"b"->b,"c"->c,"Parameter"->d|>];

ecfMessages={
 "notpoly"->"The invariants c4, c6 and Delta of the model `1` must be polynomials in `2`; clear denominators first (rescale x -> x/k^2, y -> y/k^3, i.e. a_i -> k^i a_i).",
 "badn"->"n = `1` is too small: the model has a pole at infinity (the coefficient a_i must have degree <= i n in t). Use Automatic or a larger n.",
 "nonminimal"->"The model is not minimal at `1` (ord c4 >= 4 and ord c6 >= 6); divide out the common factor and rescale before classifying.",
 "badN"->"Tate-Kubert families are provided for N = 4, 5, 6, 7; received `1`."};

ecfFuncs={ECPKodairaType,ECPFibreAt,ECPFibreAtInfinity,ECPFibreList,ECPJFunction,ECPCoulombDimension,ECPGaugeAlgebra,ECPTateForm,ECPTorsionFamily};
ecInstallMessages[ecfFuncs,ecCurveMessages];
ecInstallMessages[ecfFuncs,ecArgMessages];
ecInstallMessages[ecfFuncs,ecfMessages];
Scan[ecInstallCatchAll,ecfFuncs];

(* 18. PRIME-DIVISOR COUNTS AND RIGOROUS RANK BOUNDS (Lozano-Robledo, Thm 2.6.4 and Prop 2.9.1) *)

ecNu[n_Integer]:=Length[primeFactorsOf[n]];

ECPPrimeDivisorCount[n_Integer]:=If[n==0,(Message[ECPPrimeDivisorCount::zero,n];$Failed),ecNu[n]];

ECPPrimeDivisorCount[{A_,B_}]:=Module[{delta},
  If[!ecShortChecks[{A,B},ECPPrimeDivisorCount],Return[$Failed]];
  If[!(IntegerQ[A]&&IntegerQ[B]),Message[ECPPrimeDivisorCount::nonintegral,{A,B}];Return[$Failed]];
  delta=-16 (4 A^3+27 B^2);
  ecNu[delta]];

ECPPrimeDivisorCount[curve:Except[_Integer|{_,_}]]:=Module[{c},
  c=ecLong[curve,ECPPrimeDivisorCount];
  If[c===$Failed,Return[$Failed]];
  If[!AllTrue[c,IntegerQ],Message[ECPPrimeDivisorCount::nonintegral,c];Return[$Failed]];
  ecNu[ecDisc[c]]];

(* integer roots of the monic integer cubic x^3+a x^2+b x+c *)
ecIntCubicRoots[{a_,b_,c_}]:=Module[{x},
  Sort[Cases[FactorList[x^3+a x^2+b x+c],{f_,_}/;Exponent[f,x]==1:>-Coefficient[f,x,0]/Coefficient[f,x,1]]]];

(* Theorem 2.6.4 for y^2 = x(x^2 + a x + b) *)
ecThm264[a_Integer,b_Integer]:=Max[0,ecNu[a^2-4b]+ecNu[b]-1];

ecRankBoundData[c_List]:=Module[{x,b2,b4,b6,cub,cands={},loc,m,aa,lst,e,a2p,a4p,a6p,rts,r3,dl},
  b2=c[[1]]^2+4 c[[2]];b4=2 c[[4]]+c[[1]] c[[3]];b6=c[[3]]^2+4 c[[5]];
  (* rational 2-torsion <-> rational root of 4x^3+b2 x^2+2 b4 x+b6 *)
  cub=4 x^3+b2 x^2+2 b4 x+b6;
  rts=Sort[Cases[FactorList[cub],{f_,_}/;Exponent[f,x]==1:>-Coefficient[f,x,0]/Coefficient[f,x,1]]];
  If[rts==={},Return[<|"Bound"->Missing["NoRational2Torsion"],"Candidates"-><||>,"TwoTorsionX"->{}|>]];
  (* (a) m + 2a - 1 from the Kodaira/Tate data *)
  loc=ECPLocalData[c];
  If[AssociationQ[loc]&&AllTrue[Values[loc],AssociationQ],
   m=Count[Values[loc],_?(#["f"]==1&)];aa=Count[Values[loc],_?(#["f"]>=2&)];
   AppendTo[cands,"m+2a-1"->Max[0,m+2aa-1]]];
  (* (b) nu(a^2-4b)+nu(b)-1, needs a1,a3 even so that the model reduces to y^2 = cubic over Z;
     otherwise use the scaled model W^2 = X^3 + b2 X^2 + 8 b4 X + 16 b6 (isomorphic over Q) *)
  If[EvenQ[c[[1]]]&&EvenQ[c[[3]]],
   a2p=c[[2]]+c[[1]]^2/4;a4p=c[[4]]+c[[1]] c[[3]]/2;a6p=c[[5]]+c[[3]]^2/4;
   lst=Table[{e,3 e+a2p,3 e^2+2 a2p e+a4p},{e,ecIntCubicRoots[{a2p,a4p,a6p}]}],
   lst=Table[{e,3 e+b2,3 e^2+2 b2 e+8 b4},{e,ecIntCubicRoots[{b2,8 b4,16 b6}]}]];
  If[lst=!={},
   AppendTo[cands,"nu(a^2-4b)+nu(b)-1"->Min[ecThm264@@Rest[#]&/@lst]];
   (* (c) Proposition 2.9.1: three integral roots *)
   If[Length[lst]==3,
    r3=lst[[All,1]];
    dl=16 ((r3[[1]]-r3[[2]])(r3[[1]]-r3[[3]])(r3[[2]]-r3[[3]]))^2;
    AppendTo[cands,"2 nu(Delta)"->2 ecNu[dl]]]];
  <|"Bound"->Min[Values[Association[cands]]],"Candidates"->Association[cands],
    "TwoTorsionX"->rts,"BadPrimes"->If[AssociationQ[loc],Keys[loc],{}]|>];

ECPRankBound[curve_,opt_:Automatic]:=Module[{c,d},
  If[!MemberQ[{Automatic,"Details"},opt],Message[ECPRankBound::badopt,opt];Return[$Failed]];
  c=ecLong[curve,ECPRankBound];
  If[c===$Failed,Return[$Failed]];
  If[!AllTrue[c,IntegerQ],Message[ECPRankBound::nonintegral,c];Return[$Failed]];
  d=ecRankBoundData[c];
  If[MissingQ[d["Bound"]],Message[ECPRankBound::no2tors,c]];
  If[opt==="Details",d,d["Bound"]]];

ecrbFuncs={ECPPrimeDivisorCount,ECPRankBound};
ecInstallMessages[ecrbFuncs,ecCurveMessages];
ecInstallMessages[ecrbFuncs,ecArgMessages];
Scan[ecInstallCatchAll,ecrbFuncs];

ecInstallMessages[{ECPPointOrder,ECPPointOrderFp},ecArgMessages];
Scan[ecInstallCatchAll,Join[ecCatchAllFuncs,{ECPPointOrder,ECPPointOrderFp}]];

End[];

ECPack`$ECPVersion="1.0";

(* Load-time banner. To suppress it, evaluate  $ECPQuietLoad = True;  BEFORE loading the package. *)
If[!TrueQ[Global`$ECPQuietLoad],
 Print["ECPack loaded: ",Length[Names["ECPack`ECP*"]]," commands.\n",

"Copyright (c) 2026, by B. Ananthanarayan, Darsh R. Bhatt and Parastoo Taghizadeh Asl

",
 "ECPack comes with ABSOLUTELY NO WARRANTY.",

"\nThis is free software, and you are welcome to redistribute it under the terms of the GNU Public Licence. For assistance consult Darsh R. Bhatt @ darshbhatt.ssa@gmail.com\n",
  "  ?ECP*  lists every command."
  ]];

EndPackage[];
