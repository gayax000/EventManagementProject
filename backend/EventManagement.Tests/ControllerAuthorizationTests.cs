using System.Reflection;
using EventManagement.Api.Controllers;
using Microsoft.AspNetCore.Authorization;
using Xunit;

namespace EventManagement.Tests;

public class ControllerAuthorizationTests
{
    [Theory]
    [InlineData(typeof(AiWorkflowController), nameof(AiWorkflowController.ApproveWorkflow), "Manager,Admin")]
    [InlineData(typeof(AiWorkflowController), nameof(AiWorkflowController.CreateResource), "Manager,Admin")]
    [InlineData(typeof(VenuesController), nameof(VenuesController.VerifyVendor), "Manager,Admin")]
    [InlineData(typeof(VenuesController), nameof(VenuesController.DeleteVendor), "Manager,Admin")]
    [InlineData(typeof(PaymentsController), nameof(PaymentsController.VerifyPayment), "Manager,Admin")]
    [InlineData(typeof(PaymentsController), nameof(PaymentsController.GetRevenueForecast), "Manager,Admin")]
    public void ControllerEndpoint_HasRequiredAuthorizeAttribute(Type controllerType, string methodName, string expectedRoles)
    {
        var method = controllerType.GetMethod(methodName);
        Assert.NotNull(method);

        var authorizeAttr = method!.GetCustomAttribute<AuthorizeAttribute>();
        Assert.NotNull(authorizeAttr);
        Assert.Equal(expectedRoles, authorizeAttr!.Roles);
    }
}
