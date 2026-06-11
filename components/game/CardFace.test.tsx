import { test, expect } from 'vitest';
import { render } from '@testing-library/react';
import CardFace from './CardFace';

test('renders the correct number of pips for number cards', () => {
  const { container } = render(<CardFace rank="7" suit="clubs" />);
  expect(container.querySelectorAll('[data-pip]')).toHaveLength(7);
});

test('renders corner indices with rank text', () => {
  const { getAllByText } = render(<CardFace rank="Q" suit="hearts" />);
  expect(getAllByText('Q').length).toBeGreaterThanOrEqual(2);
});
