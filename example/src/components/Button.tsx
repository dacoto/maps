import { Pressable, Text, StyleSheet, type PressableProps } from 'react-native';

interface ButtonProps extends Omit<PressableProps, 'style'> {
  title: string;
}

export function Button({ title, disabled, ...props }: ButtonProps) {
  return (
    <Pressable
      style={({ pressed }) => [
        styles.button,
        pressed && !disabled && styles.pressed,
        disabled && styles.disabled,
      ]}
      disabled={disabled}
      {...props}
    >
      <Text style={[styles.text, disabled && styles.textDisabled]}>
        {title}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    flexGrow: 1,
    minWidth: '45%',
  },
  pressed: {
    opacity: 0.7,
  },
  disabled: {
    backgroundColor: '#A0A0A0',
  },
  text: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  textDisabled: {
    color: '#E0E0E0',
  },
});
