using EventManagement.Core.DTOs;
using Xunit;

namespace EventManagement.Tests;

public class PagedResultTests
{
    [Fact]
    public void PagedResult_CalculatesTotalPagesAndNavigationCorrectly()
    {
        // Arrange
        var paged = new PagedResult<string>
        {
            Items = new[] { "Event 1", "Event 2", "Event 3" },
            TotalCount = 25,
            PageNumber = 2,
            PageSize = 10
        };

        // Assert
        Assert.Equal(3, paged.TotalPages);
        Assert.True(paged.HasPreviousPage);
        Assert.True(paged.HasNextPage);
    }

    [Fact]
    public void PagedResult_OnFirstPage_HasPreviousPageIsFalse()
    {
        var paged = new PagedResult<int>
        {
            Items = new[] { 1, 2, 3, 4, 5 },
            TotalCount = 10,
            PageNumber = 1,
            PageSize = 5
        };

        Assert.Equal(2, paged.TotalPages);
        Assert.False(paged.HasPreviousPage);
        Assert.True(paged.HasNextPage);
    }
}
