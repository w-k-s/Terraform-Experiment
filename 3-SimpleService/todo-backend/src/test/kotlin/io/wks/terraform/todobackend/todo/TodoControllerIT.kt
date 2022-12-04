package io.wks.terraform.todobackend.todo

import com.fasterxml.jackson.databind.ObjectMapper
import io.wks.terraform.todobackend.config.TestConfiguration
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.*

@ActiveProfiles("test")
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    classes = [TestConfiguration::class]
)
@AutoConfigureMockMvc
internal class TodoControllerIT {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var todoDao: TodoDao

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @BeforeEach
    fun setup() {
        todoDao.deleteAll()
    }

    @Nested
    inner class CreateTodo {

        @Test
        fun `GIVEN description WHEN it is not blank THEN todo is created`() {
            createTodo("""{"description":"Read"}""")
                .andExpect {
                    status {
                        isOk()
                    }
                    content {
                        json("""{"description":"Read"}""")
                    }
                }
        }

        @Test
        fun `GIVEN description WHEN it is blank THEN bad request`() {
            createTodo("""{"description":""}""")
                .andExpect {
                    status {
                        isBadRequest()
                    }
                    content {
                        json(
                            """{
                            "type": "about:blank",
                            "title": "Bad Request",
                            "status": 400,
                            "detail": "The information provided is incorrect",
                            "instance": "/api/v1/todos",
                            "createTodo.request.description": "must not be blank"
                        }""", strict = true
                        )
                    }
                }
        }
    }

    @Nested
    inner class ListTodos {

        @Test
        fun `GIVEN todos WHEN listed THEN todos returned`() {
            // Given
            createTodo("""{"description":"Drink Milk"}""")
                .andExpect { status { isOk() } }

            createTodo("""{"description":"Kick Ass"}""")
                .andExpect { status { isOk() } }

            // WHEN, THEN

            mockMvc
                .get("/api/v1/todos")
                .andExpect {
                    status { isOk() }
                    content {
                        json(
                            """{
                            "todos": [{
                                "description": "Drink Milk",
                                "createdAt": "1970-01-01T00:00:00Z",
                                "completedAt": null
                            }, {
                                "description": "Kick Ass",
                                "createdAt": "1970-01-01T00:00:00Z",
                                "completedAt": null
                            }]
                        }"""
                        )
                    }
                }
        }

        @Test
        fun `GIVEN no todos WHEN listed THEN empty list`() {
            mockMvc
                .get("/api/v1/todos")
                .andExpect {
                    status { isOk() }
                    content {
                        json(
                            """{
                            "todos": []
                        }""", strict = true
                        )
                    }
                }
        }
    }

    @Nested
    inner class CompleteTodos {

        @BeforeEach
        fun setup() {
            todoDao.deleteAll()
        }

        @Test
        fun `GIVEN a todo exists WHEN it is completed THEN completedAt set`() {
            val todoResponse = createTodo("""{"description": "Drink Milk"}""")
                .andExpect { status { isOk() } }
                .andReturn()
                .response
                .contentAsString
                .let { objectMapper.readValue(it, Todo::class.java) }


            createTodo("""{"description": "Kick ass"}""")
                .andExpect { status { isOk() } }

            mockMvc
                .patch("/api/v1/todos/${todoResponse.id}/complete")
                .andExpect {
                    status { isOk() }
                    content {
                        json(
                            """{
                            "description": "Drink Milk",
                            "createdAt": "1970-01-01T00:00:00Z",
                            "completedAt": "1970-01-01T00:00:00Z"
                        }"""
                        )
                    }
                }
        }

        @Test
        fun `GIVEN a todo exists WHEN it is completed THEN not found`() {
            mockMvc
                .patch("/api/v1/todos/${Long.MAX_VALUE}/complete")
                .andExpect {
                    status { isNotFound() }
                    content {
                        json(
                            """{
                                "type": "about:blank",
                                "title": "Not Found",
                                "status": 404,
                                "detail": "Todo with id '9223372036854775807' not found",
                                "instance": "/api/v1/todos/9223372036854775807/complete"
                            }"""
                        )
                    }
                }
        }
    }

    @Nested
    inner class DeleteTodos {

        @Test
        fun `GIVEN a todo exists WHEN it is deleted THEN ok`() {
            val todoResponse = createTodo("""{"description": "Drink Milk"}""")
                .andExpect { status { isOk() } }
                .andReturn()
                .response
                .contentAsString
                .let { objectMapper.readValue(it, Todo::class.java) }

            mockMvc
                .delete("/api/v1/todos/${todoResponse.id}")
                .andExpect {
                    status { isNoContent() }
                    content {
                        string("")
                    }
                }
        }

        @Test
        fun `GIVEN a todo does not exist WHEN it is deleted THEN ok`() {
            mockMvc
                .delete("/api/v1/todos/${Long.MAX_VALUE}")
                .andExpect {
                    status { isNoContent() }
                    content {
                        string("")
                    }
                }
        }
    }

    private fun createTodo(requestBody: String): ResultActionsDsl {
        return mockMvc.post("/api/v1/todos") {
            contentType = MediaType.APPLICATION_JSON
            content = requestBody
        }
    }
}
