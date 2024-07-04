import 'package:mink_utils/mink_utils.dart';
import 'package:test/test.dart';

void main() {
  group("logic", () {
    test('binary comp predicate builder', () {
      var pred = BinaryComparison.gt.predicate(5);
      expect(pred(4), false);
      expect(pred(5), false);
      expect(pred(6), true);

      pred = BinaryComparison.geq.predicate(5);
      expect(pred(4), false);
      expect(pred(5), true);
      expect(pred(6), true);

      pred = BinaryComparison.le.predicate(5);
      expect(pred(4), true);
      expect(pred(5), false);
      expect(pred(6), false);

      pred = BinaryComparison.leq.predicate(5);
      expect(pred(4), true);
      expect(pred(5), true);
      expect(pred(6), false);

      pred = UnaryLogicalConnective.negate
          .transform(BinaryComparison.leq.predicate(5));
      expect(pred(4), false);
      expect(pred(5), false);
      expect(pred(6), true);

      pred = BinaryComparison.leq.predicate(5);
      expect(pred(4), true);
      expect(pred(5), true);
      expect(pred(6), false);

      pred = BinaryComparison.eq.predicate(5);
      expect(pred(4), false);
      expect(pred(5), true);
      expect(pred(6), false);

      pred = BinaryComparison.neq.predicate(5);
      expect(pred(4), true);
      expect(pred(5), false);
      expect(pred(6), true);
    });

    test("ternary comp builder", () {
      var pred = TernaryComparison.inside.predicate(0, 1);
      expect(pred(-1), false);
      expect(pred(0), false);
      expect(pred(0.5), true);
      expect(pred(1), false);

      pred = TernaryComparison.insideEq.predicate(0, 1);
      expect(pred(-1), false);
      expect(pred(0), true);
      expect(pred(0.5), true);
      expect(pred(1), true);

      pred = TernaryComparison.outside.predicate(0, 1);
      expect(pred(-1), true);
      expect(pred(0), false);
      expect(pred(0.5), false);
      expect(pred(1), false);

      pred = TernaryComparison.outsideEq.predicate(0, 1);
      expect(pred(-1), true);
      expect(pred(0), true);
      expect(pred(0.5), false);
      expect(pred(1), true);
    });

    test("predicat combinations", () {
      var pred1 = BinaryComparison.eq.predicate(5);
      var pred2 = BinaryComparison.neq.predicate(5);

      expect(pred1.join(pred2, BinaryLogicalConnective.or)(5), true);
      expect(pred1.join(pred2, BinaryLogicalConnective.and)(5), false);
      expect(pred1.join(pred2, BinaryLogicalConnective.xor)(5), true);

      expect(pred1.join(pred1, BinaryLogicalConnective.or)(5), true);
      expect(pred1.join(pred1, BinaryLogicalConnective.and)(5), true);
      expect(pred1.join(pred1, BinaryLogicalConnective.xor)(5), false);

      expect(pred2.join(pred2, BinaryLogicalConnective.or)(5), false);
      expect(pred2.join(pred2, BinaryLogicalConnective.and)(5), false);
      expect(pred2.join(pred2, BinaryLogicalConnective.xor)(5), false);

      var relation = BinaryLogicalConnective.and;
      var pred = pred1.join(
          pred1.join(
              pred1.join(
                pred1.join(
                  pred1.join(
                    pred1,
                    relation,
                  ),
                  relation,
                ),
                relation,
              ),
              relation),
          relation);

      expect(pred(5), true);

      relation = BinaryLogicalConnective.or;
      pred = pred1.join(
          pred1.join(
              pred1.join(
                pred1.join(
                  pred1.join(
                    pred1,
                    relation,
                  ),
                  relation,
                ),
                relation,
              ),
              relation),
          relation);

      expect(pred(5), true);

      relation = BinaryLogicalConnective.xor;
      pred = pred1.join(
          pred1.join(
              pred1.join(
                pred1.join(
                  pred1.join(
                    pred1,
                    relation,
                  ),
                  relation,
                ),
                relation,
              ),
              relation),
          relation);

      expect(pred(5), false);
    });
  });
}
