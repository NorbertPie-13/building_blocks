#include "hello.h"
#include <gtest/gtest.h>

// Test the add function
TEST(HelloTest, AddFunction)
{
    EXPECT_EQ(4, add(2, 2));
    EXPECT_EQ(0, add(0, 0));
    EXPECT_EQ(-2, add(-1, -1));
    EXPECT_EQ(0, add(-5, 5));
    EXPECT_EQ(100, add(50, 50));
}

// Main function needed to run the tests
int main(int argc, char **argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}