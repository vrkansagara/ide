function sum(a, b) {
  return a + b;
}

module.exports = sum;

import {expect, jest, test} from '@jest/globals';

jest.useFakeTimers();

test('some test', () => {
  expect(Date.now()).toBe(0);
});
