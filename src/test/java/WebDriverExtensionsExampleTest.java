import org.junit.Test;
import org.junit.runner.RunWith;

import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.WebElement;

import com.github.webdriverextensions.junitrunner.WebDriverRunner;
import com.github.webdriverextensions.junitrunner.annotations.*;
import static com.github.webdriverextensions.Bot.*;
import static java.util.concurrent.TimeUnit.SECONDS;

@RunWith(WebDriverRunner.class)
@Chrome
public class WebDriverExtensionsExampleTest {

    @FindBy(name = "q")
    private WebElement queryInput;
    @FindBy(name = "btnK")
    private WebElement searchButton;
    @FindBy(id = "search")
    private WebElement searchResult;

    @Test
    public void searchGoogleForHelloWorldTest() {
        open("http://www.google.com");
        assertCurrentUrlContains("google");

        type("Hello World", queryInput);
        pressEnter(queryInput);

        waitFor(3, SECONDS);
        assertTextContains("Hello World", searchResult);
    }
}
