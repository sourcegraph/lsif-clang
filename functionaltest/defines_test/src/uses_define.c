
// Constant define, does it know the definition
#define JUST_A_CONSTANT 3


#define DUMB_EXAMPLE(one, three) \
  my_function(one, 10, three)


int my_function(int one, int two, int three) 
{
  return one + two + three;
}

int main()
{
  DUMB_EXAMPLE(1, 3);

  my_function(1, 2, 3);

  my_function(1, 2, JUST_A_CONSTANT);

  return 0;
}

// TODO:
// #define map_new(T, U) map_##T##_##U##_new
