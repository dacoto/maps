export const randomFrom = <T>(arr: T[]): T =>
  arr[Math.floor(Math.random() * arr.length)]!;

export const randomInt = (min: number, max: number) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

export const randomLetter = () =>
  String.fromCharCode(65 + Math.floor(Math.random() * 26));
